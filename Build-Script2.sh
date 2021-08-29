#!/bin/sh -e
Sudo pacman -S lvm2 --noconfirm
mkinitcpio -p linux
pacman -S grub --noconfirm
pacman -Sy lvm2 networkmanager --noconfirm
systemctl enable NetworkManager
ln -s /usr/share/zoneinfo/America/Phoenix /etc/localtime
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
rm -rf /etc/localtime
hwclock --systohc
pacman -Sy vim sudo iwd systemd openssh nano networkmanager firefox grub efibootmgr --noconfirm 
vim /etc/locale.gen
