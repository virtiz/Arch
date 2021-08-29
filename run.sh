#!/bin/sh -e

######Define Vairables#####
echo -n "What username would you like? "
read username
echo -n "What HostName would you like? "
read hostname
echo -n "What drive do you want to install on? ie: /dev/vda "
read device

export lang="en_US.UTF-8"
export locale="en_US.UTF-8 UTF-8"
export timezone="America/Phoenix"
export $username
export $hostname

####Partition Drive####
sudo parted $device mklabel gpt
sudo parted $device mkpart ESP fat32 1MiB 513MiB
sudo parted $device set 1 boot on
sudo parted $device name 1 efi
sudo parted $device mkpart primary 513MiB 800MiB
sudo parted $device name 2 boot
sudo parted $device mkpart primary 800MiB 100%
sudo parted $device name 3 lvm
sudo parted $device set 3 lvm on
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

####Setup Configs####
pacstrap /mnt base linux linux-firmware --noconfirm
genfstab -U -p /mnt > /mnt/etc/fstab
awk '{sub(/"f block f"/,"f block lvm2 f")}1' < /mnt/etc/mkinitcpio.conf  > ./temp ; cp ./temp /mnt/etc/mkinitcpio.conf 

#Function Buildout
Buildout(){
mkinitcpio -p linux
pacman -Sy  efibootmgr vim base-devel lvm2 nano grub lvm2 networkmanager sudo iwd systemd openssh nano firefox efibootmgr --noconfirm
echo $hostname > /etc/hostname
ln -s /usr/share/zoneinfo/$timezone /etc/localtime
echo "LANG=$lang" >> /etc/locale.conf
sed -i "/$locale/s/^#//" /etc/locale.gen
sed -i '/^# %wheel ALL=(ALL) NOPASSWD: ALL/s/^# //' /etc/sudoers
locale-gen
hwclock --systohc
systemctl enable {iwd.service,sshd.service,NetworkManager}
echo "Password for root"
passwd root
useradd -m -g users -G wheel $username
echo "Password for "$username
passwd $username

#add firmware
mkdir ./temp && cd ./temp
git clone https://aur.archlinux.org/aic94xx-firmware.git
git clone https://aur.archlinux.org/wd719x-firmware.git
cd aic94xx-firmware && sudo -u $username makepkg -sri --noconfirm
cd /temp/wd719x-firmware  && sudo -u $username makepkg -sri --noconfirm
cd / && rm -r /temp 
sudo pacman -Syyu

#install bootloader
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux

}
export -f Buildout
arch-chroot /mnt /bin/bash -c "Buildout"
echo "you can reboot now"
#issues
#locale not saving, username is blank, firmware not installing
