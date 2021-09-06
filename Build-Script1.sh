#!/bin/sh
echo -n "What username would you like? "
read username
echo -n "What HostName would you like? "
read hostname
echo -n "What drive do you want to install on? ie: /dev/vda "
read device
echo -n "what is your locale?  ex: America/Phoenix "
read locale
sudo parted $device mklabel gpt
sudo parted $device mkpart ESP fat32 1MiB 513MiB
sudo parted $device set 1 boot on
sudo parted $device name 1 efi
sudo parted $device mkpart primary 513MiB 800MiB
sudo parted $device name 2 boot
sudo parted $device mkpart primary 800MiB 100%
sudo parted $device name 3 lvm
sudo parted $device print
sudo parted $device set 3 lvm on
sudo parted $device print
pvcreate $device"3"
vgcreate lvm $device"3"
lvcreate -n root -L 15G lvm
lvcreate -n swap -L 10G lvm
lvcreate -n home -l 100%FREE lvm
mkfs.fat -F32 $device"1"
mkfs.ext2 $device"2"
mkfs.btrfs -L root /dev/lvm/root
mkfs.btrfs -L home /dev/lvm/home
mkswap /dev/lvm/swap
swapon /dev/lvm/swap
mount /dev/lvm/root /mnt
mkdir /mnt/{home,boot}
mount $device"2" /mnt/boot
mkdir /mnt/boot/efi
mount $device"1" /mnt/boot/efi
mount /dev/lvm/home /mnt/home
pacstrap /mnt base base-devel linux linux-firmware efibootmgr vim btrfs-progs lvm2 --noconfirm
genfstab -U -p /mnt > /mnt/etc/fstab
cp mkinitcpio.conf /mnt/etc/mkinitcpio.conf
cat ./sudoers | awk '{sub(/chris/,"'$username'")}1' > /mnt/etc/sudoers
cp locale.gen /mnt/etc/locale.gen
cat ./Build-Script2.sh | awk '{sub(/chris/,"'$username'")}1' | awk '{sub(/checklocale/,"'$locale'")}1' | awk '{sub(/checkhost/,"'$hostname'")}1' >  /mnt/Build-Script2.sh
chmod +x /mnt/Build-Script2.sh
arch-chroot /mnt /bin/bash
