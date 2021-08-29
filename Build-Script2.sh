#!/bin/sh
echo -n "what is your locale?  ex: America/Phoenix"
read local
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
echo arch1 > /etc/hostname
sudo pacman -Syyu
systemctl enable {iwd.service,sshd.service}
echo "Password for root"
passwd root
useradd -m -g users -G wheel -s /bin/bash chris
echo "Password for your user account"
passwd chris
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux
exit
reboot
