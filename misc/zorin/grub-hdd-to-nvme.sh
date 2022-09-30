#! /bin/bash
# shellcheck disable=SC2086
set -euxo pipefail


# Calculate preferred swap partition size for hibernation
TOTAL_MEM=$(awk '{if ($1 == "MemTotal:") print $2}' /proc/meminfo)
EXTRA_SWAP=$((2 * 1024 * 1024))
TOTAL_SWAP="$((TOTAL_MEM + EXTRA_SWAP))K"  # KiB

SOURCE_DEV='/dev/sda'
TARGET_DEV='/dev/nvme0n1'
EFI_BLOCK="${SOURCE_DEV}1"
SOURCE_ROOT="${SOURCE_DEV}2"

# clear root drive
sgdisk -Z $TARGET_DEV
# create swap
sgdisk -n1:1M:+$TOTAL_SWAP -t1:8200 $TARGET_DEV
# create root
sgdisk -n2:0:0 -t2:8304 $TARGET_DEV

mapfile -t new_blocks < <(lsblk -no PATH $TARGET_DEV)
new_swap_blk="${new_blocks[1]}"
new_root_blk="${new_blocks[2]}"

# notify kernel
partprobe $TARGET_DEV
sleep 1

# make new swap partition
mkswap -L swap $new_swap_blk

# copy over the old partition
dd if=$SOURCE_ROOT of=$new_root_blk bs=4M status=progress

# randomize the new root's guid
sgdisk -G $TARGET_DEV

# make new mount points
mkdir /mnt/boot
mkdir /target

# mount the og boot and new root
mount $EFI_BLOCK /mnt/boot
mount $new_root_blk /target

# recurse copy the boot folder to efi
rm -d /target/boot/efi
cp -fLr /target/boot/* /mnt/boot
# remove old boot files
rm -rf /target/boot/*

# unmount old efi
umount /mnt/boot

# mount in preparation for chroot
mount         $EFI_BLOCK   /target/boot
mount --bind  /dev         /target/dev
mount --bind  /dev/pts     /target/dev/pts
mount --bind  /proc        /target/proc
mount --bind  /sys         /target/sys

# add modules for nvme in initramfs
cat <<- EOF >> /target/etc/initramfs-tools/modules
	nvme
	vmd
EOF

# find the uuid of each fstab entry
root_uuid=$(lsblk -no UUID $new_root_blk)
efi_uuid=$(lsblk -no UUID $EFI_BLOCK)
swap_uuid=$(lsblk -no UUID $new_swap_blk)

# write the new fstab
cat <<- EOF > /target/etc/fstab
	UUID=$root_uuid  /      ext4  errors=remount-ro  0 1
	UUID=$efi_uuid   /boot  vfat  umask=0077         0 1
	UUID=$swap_uuid  none   swap  sw                 0 0
EOF

# enable hibernation to swap
sed -i "s;\(GRUB_CMDLINE_LINUX_DEFAULT\)=\"\(.*\)\";\1=\"\2 resume=UUID=$swap_uuid\";" \
	/target/etc/default/grub

# copy the zorin theme to esp so that grub can find it before nvme load
cp -r /usr/share/grub/themes/zorin /target/boot/EFI/ubuntu
sed -i 's|\(GRUB_THEME\)=.*|\1=/boot/EFI/ubuntu/zorin/theme.txt|' \
	/target/etc/default/grub

# maybe needed to reduce the size of initramfs image
#echo 'MODULES=dep' > /target/etc/initramfs-tools/conf.d/modules

# clear the original root partition
# we don't want it picked up by os-prober
sgdisk -d2 $SOURCE_DEV

# chroot and reconfigure bootloader + initramfs
chroot /target /bin/bash -x <<- EOF
	set -ev
	# delete the old initramfs images
	update-initramfs -d -k all
	# generate new ones from scratch
	update-initramfs -c -k all
	# re-write the grub config
	grub-mkconfig -o /boot/EFI/ubuntu/grub.cfg
	# install grub again
	grub-install \
		--efi-directory /boot \
		--bootloader-id ubuntu
EOF

# clean up the chroot mounts
umount /target/sys
umount /target/proc
umount /target/dev/pts
umount /target/dev
umount /target/boot
umount /target

rm -d /mnt/boot
rm -d /target
