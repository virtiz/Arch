#!/bin/sh
echo -n "What username would you like? "
read username
chmod +x  ./Build-Script2.sh
sudo parted /dev/vda mklabel gpt
sudo parted /dev/vda mkpart ESP fat32 1MiB 513MiB
sudo parted /dev/vda set 1 boot on
sudo parted /dev/vda name 1 efi
sudo parted /dev/vda mkpart primary 513MiB 800MiB
sudo parted /dev/vda name 2 boot
sudo parted /dev/vda mkpart primary 800MiB 100%
sudo parted /dev/vda name 3 lvm
sudo parted /dev/vda print
sudo parted /dev/vda set 3 lvm on
sudo parted /dev/vda print
pvcreate /dev/vda3
vgcreate lvm /dev/vda3
lvcreate -n root -L 15G lvm
lvcreate -n swap -L 10G lvm
lvcreate -n home -l 100%FREE lvm
lvs
mkfs.fat -F32 /dev/vda1
mkfs.ext2 /dev/vda2
mkfs.btrfs -L root /dev/lvm/root
mkfs.btrfs -L home /dev/lvm/home
mkswap /dev/lvm/swap
swapon /dev/lvm/swap
mount /dev/lvm/root /mnt
mkdir /mnt/{home,boot}
mount /dev/vda2 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/vda1 /mnt/boot/efi
mount /dev/lvm/home /mnt/home
pacstrap /mnt base base-devel linux linux-firmware efibootmgr vim btrfs-progs lvm2 --noconfirm
genfstab -U -p /mnt > /mnt/etc/fstab
cp mkinitcpio.conf /mnt/etc/mkinitcpio.conf
cat ./sudoers | awk '{sub(/chris/,"'$username'")}1' > /mnt/etc/sudoers
cp locale.gen /mnt/etc/locale.gen
cat ./Build-Script2.sh | awk '{sub(/chris/,"'$username'")}1' > /mnt/Build-Script2.sh
arch-chroot /mnt /bin/bash
