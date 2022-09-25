#! /bin/bash
set -eux

OS_TARGET=/dev/nvme0n1
OS_ROOT=/dev/nvme0n1p3
# OS_TARGET=/dev/vda
# OS_ROOT=/dev/vda2
EFI_TARGET=/dev/sda
EFI_PART=/dev/sda1

sgdisk -Z $EFI_TARGET
sgdisk -n1:1M:500M -t1:ef00 $EFI_TARGET

partprobe $EFI_TARGET
sleep 1

mkfs.vfat -F32 $EFI_PART

mkdir -p /target

mount $OS_ROOT /target

# mount in preparation for chroot
mount         $EFI_PART    /target/boot/efi
mount --bind  /dev         /target/dev
mount --bind  /dev/pts     /target/dev/pts
mount --bind  /proc        /target/proc
mount --bind  /sys         /target/sys

# chroot and reconfigure bootloader + initramfs
chroot /target /bin/bash -x <<- EOF
	apt-add-repository -y ppa:rodsmith/refind
	apt update
	apt upgrade -y
	apt install -y refind

	cd /tmp

	if [ ! -f NvmExpressDxe.efi ];
	then
		wget 'https://github.com/CloverHackyColor/CloverBootloader/releases/download/5149/CloverV2-5149.zip'
		7z e ./CloverV2-5149.zip CloverV2/EFI/CLOVER/drivers/off/UEFI/Other/NvmExpressDxe.efi
	fi

	refind-install

	mkdir -p /boot/efi/EFI/refind/drivers_x64
	cp NvmExpressDxe.efi /boot/efi/EFI/refind/drivers_x64
EOF

clean up the chroot mounts
umount /target/sys
umount /target/proc
umount /target/dev/pts
umount /target/dev
umount /target/boot/efi
umount /target
