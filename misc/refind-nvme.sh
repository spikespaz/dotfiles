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
	shopt -s extglob

	apt-add-repository -y ppa:rodsmith/refind
	apt update
	apt upgrade -y
	apt install -y refind

	cd /tmp

	REFIND_VER='0.13.3.1'

	if [ ! -f refind-bin.zip ]
	then
		wget \
			-O refind-bin.zip \
			"https://cfhcable.dl.sourceforge.net/project/refind/$REFIND_VER/refind-bin-$REFIND_VER.zip"
		7z x ./refind-bin.zip
	fi

	if [ ! -f NvmExpressDxe.efi ]
	then
		wget \
			-O clover.zip \
			'https://github.com/CloverHackyColor/CloverBootloader/releases/download/5149/CloverV2-5149.zip'
		7z e ./clover.zip CloverV2/EFI/CLOVER/drivers/off/UEFI/Other/NvmExpressDxe.efi
	fi

	REFIND_DIR='/boot/efi/EFI/refind'
	DRIVERS_DIR="$REFIND_DIR/drivers_x64"
	REFIND_FROM="refind-bin-$REFIND_VER/refind"

	mkdir -p $DRIVERS_DIR

	# copy icons over
	cp -r $REFIND_FROM/icons $REFIND_DIR

	# copy the boot manager
	cp $REFIND_FROM/refind_x64.efi $REFIND_DIR

	# copy the default config and modify
	cp $REFIND_FROM/refind.conf-sample $REFIND_DIR
	cp $REFIND_FROM/refind.conf-sample $REFIND_DIR/refind.conf
	sed -i 's/timeout 20/timeout 2/' $REFIND_DIR/refind.conf

	# copy drivers
	cp $REFIND_FROM/drivers_x64/ext4_x64.efi $DRIVERS_DIR
	cp NvmExpressDxe.efi $DRIVERS_DIR

	# add the entry to nvram
	efibootmgr -c -l '\\EFI\\refind\\refind_x64.efi' -L rEFInd
EOF

# clean up the chroot mounts
umount /target/sys
umount /target/proc
umount /target/dev/pts
umount /target/dev
umount /target/boot/efi
umount /target
