#! /usr/bin/env bash
set -eu

# Adapted from <https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html#root-on-zfs>

##### PAREMETERS #####

# Specify the drive to partition for install
TARGET_DISK='/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_23251F801658'
BOOT_PART="${TARGET_DISK}-part1"
SWAP_PART="${TARGET_DISK}-part2"
ROOT_PART="${TARGET_DISK}-part3"
POOL_NAME='intrepid'
BOOT_LABEL='INTRPD'

# Calculate preferred swap partition size for hibernation
TOTAL_MEM=$(awk '{if ($1 == "MemTotal:") print $2}' /proc/meminfo)
# Some forgiveness if memory was full when hibernating
EXTRA_SWAP=$((2 * 1024 * 1024))
TOTAL_SWAP="$((TOTAL_MEM + EXTRA_SWAP))K" # KiB

##### PARTITIONING #####

# Wipe the partition table
# sgdisk -Z $TARGET_DISK

# Because nothing behaves the way you expect
wipefs -a -q $TARGET_DISK

# New random UUID
sgdisk -UR $TARGET_DISK

# Create boot partition (ef00 = EFI system partition)
sgdisk  -n1:1M:+512M        -t1:ef00  $TARGET_DISK
# Create swap partition (8200 = Linux swap)
# shellcheck disable=SC2086
sgdisk  -n2:0:+$TOTAL_SWAP  -t2:8200  $TARGET_DISK
# Create primary partition (bf00 = Solaris root)
sgdisk  -n3:0:0             -t3:bf00  $TARGET_DISK

# Notify the kernel
partprobe $TARGET_DISK
sleep 1s

##### FORMATTING #####

# Create the root pool
zpool create \
	-o ashift=12 \
	-o autotrim=on \
	-O acltype=posixacl \
	-O dnodesize=auto \
	-O normalization=formD \
	-O atime=off \
	-O relatime=on \
	-O xattr=sa \
	-O compression=zstd-3 \
	-O canmount=off \
	-O mountpoint=none \
	-R /mnt \
	-f \
	$POOL_NAME \
	$ROOT_PART

# Declare the layout
datasets=(
	"$POOL_NAME/root"       "canmount=on   mountpoint=/           compression=zstd-fast   relatime=off"
	"$POOL_NAME/var"        "canmount=off  mountpoint=none                                relatime=off"
	"$POOL_NAME/var/lib"    "canmount=on   mountpoint=/var/lib"
	"$POOL_NAME/var/log"    "canmount=on   mountpoint=/var/log    compression=zstd-fast"
	"$POOL_NAME/var/cache"  "canmount=on   mountpoint=/var/cache  compression=zstd-fast"
	"$POOL_NAME/nix"        "canmount=on   mountpoint=/nix        compression=zstd-5      relatime=off  dedup=on"
	"$POOL_NAME/home"       "canmount=on   mountpoint=/home"
)

create_datasets() {
	while [ "$#" -gt 0 ]; do
		dataset=$1
		options=$2
		shift 2

		display="$(echo "$options" | sed 's/\s\+/, /g')"
		options="$(echo "$options" | sed 's/^\|\s\+/ -o /g')"

		echo "creating $dataset with options $display"

		zfs create $options $dataset
	done
}

# Create system datasets
create_datasets "${datasets[@]}"

# Export the pool so that the script can be run repeatedly
zpool export $POOL_NAME

# Format boot partition
mkfs.vfat -F32 -n $BOOT_LABEL $BOOT_PART

# Format the swap partition
mkswap -L swap $SWAP_PART

##### POST-SCRIPT #####

cat <<- EOF
	Partitions created and formatted successfully!

	Suggested commands:

	sudo -s <<- END
		zpool import -R /mnt ospool
		mkdir /mnt/boot
		mount -t vfat /dev/disk/by-label/BOOT /mnt/boot
	END
EOF
