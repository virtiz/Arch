#!/usr/bin/env bash
echo -n "What username would you like? "
read username
echo -n "What HostName would you like? "
read hostname
echo -n "What drive do you want to install on? ie: /dev/vda "
read device
echo -n "what is your locale?  ex: America/Phoenix "
read locale
echo -n "what is your country? ie: United States"
read country
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
pacstrap /mnt base base-devel linux linux-firmware efibootmgr vim btrfs-progs lvm2 nano --noconfirm
genfstab -U -p /mnt > /mnt/etc/fstab
cp mkinitcpio.conf /mnt/etc/mkinitcpio.conf
cat ./sudoers | awk '{sub(/chris/,"'$username'")}1' > /mnt/etc/sudoers
cp locale.gen /mnt/etc/locale.gen
pacman -Sy --needed --noconfirm reflector
reflector --country $country --age 12 --latest 10 --sort rate --protocol https --save /etc/pacman.d/mirrorlist
export $hostname
export $username
export $locale
buildout(){
pacman -S --needed --noconfirm haveged
  systemctl enable haveged
sudo pacman -S lvm2 --noconfirm
mkinitcpio -p linux
pacman -S grub --noconfirm
pacman -Sy lvm2 networkmanager --noconfirm
systemctl enable NetworkManager
ln -s /usr/share/zoneinfo/$locale /etc/localtime
echo LANG=en_US.UTF-8 > /etc/locale.conf
hwclock --systohc
pacman -Sy vim sudo iwd systemd openssh nano networkmanager firefox grub efibootmgr --noconfirm 
locale-gen
echo $hostname > /etc/hostname
sudo pacman -Syyu
systemctl enable {iwd.service,sshd.service}
echo "Password for root"
passwd root
useradd -m -g users -G wheel -s /bin/bash chris
echo "Password for chris"
passwd chris
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux
}
export -f buildout
arch-chroot /mnt /bin/bash -c "archroot"
umount -l /mnt
reboot
