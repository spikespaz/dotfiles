#!/bin/sh
set -eu

# Adapted from <https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html#root-on-zfs>

##### PAREMETERS #####

# Specify the drive to partition for install
TARGET_DISK='/dev/disk/by-id/nvme-WDC_WDS500G1B0C-00S6U0_1917CB455310'
BOOT_PART="${TARGET_DISK}-part1"
SWAP_PART="${TARGET_DISK}-part2"
ROOT_PART="${TARGET_DISK}-part3"
POOL_NAME='ospool'

# Calculate preferred swap partition size for hibernation
TOTAL_MEM=$(awk '{if ($1 == "MemTotal:") print $2}' /proc/meminfo)
EXTRA_SWAP=$(expr 2 \* 1024 \* 1024) # Some forgiveness if memory was full when hibernating
TOTAL_SWAP="$(expr $TOTAL_MEM + $EXTRA_SWAP)K" # KiB

##### PARTITIONING #####

# Wipe the partition table
sgdisk -Z $TARGET_DISK
# Create boot partition (ef00 = EFI system partition)
sgdisk  -n1:1M:+512M        -t1:ef00  $TARGET_DISK
# Create swap partition (8200 = Linux swap)
sgdisk  -n2:0:+$TOTAL_SWAP  -t2:8200  $TARGET_DISK
# Create primary partition (bf00 = Solaris root)
sgdisk  -n3:0:0             -t3:bf00  $TARGET_DISK

# Notify the kernel
partprobe $TARGET_DISK

# Pause to allow device changes
sleep 1s

##### FORMATTING #####

# Create the root pool
zpool create \
	-o ashift=12 \
	-o autotrim=on \
	-O acltype=posixacl \
	-O dnodesize=auto \
	-O normalization=formD \
	-O relatime=on \
	-O xattr=sa \
	-O compression=zstd \
	-O canmount=off \
	-O mountpoint=none \
	-R /mnt \
	-f \
	$POOL_NAME \
	$ROOT_PART

# Create system datasets
zfs create  -o canmount=on   -o moutnpoint=/      -o compression=zstd-fast                             $POOL_NAME/root
zfs create  -o canmount=off  -o mountpoint=/var                                                        $POOL_NAME/var
zfs create  -o canmount=on                                                  -o atime=off               $POOL_NAME/var/lib
zfs create  -o canmount=on                        -o compression=zstd-fast  -o atime=off               $POOL_NAME/var/log
zfs create  -o canmount=on                        -o compression=zstd-fast  -o atime=off               $POOL_NAME/var/cache
zfs create  -o canmount=on   -o mountpoint=/nix   -o compression=zstd-5     -o atime=off  -o dedup=on  $POOL_NAME/nix
zfs create  -o canmount=on   -o mountpoint=/home                                                       $POOL_NAME/home

# Format boot partition
mkfs.vfat -F32 -n boot $BOOT_PART

# Format the swap partition
mkswap -L swap $SWAP_PART

# Pause to allow device changes
sleep 1s

# Mount the boot partition
mkdir /mnt/boot
mount -t vfat /dev/disk/by-label/boot /mnt/boot
