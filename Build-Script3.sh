#!/bin/sh -e
locale-gen
echo arch1 > /etc/hostname
sudo pacman -Syyu
systemctl enable {iwd.service,sshd.service}
passwd root
useradd -m -g users -G wheel -s /bin/bash chris
passwd chris
grub-install --target=x86_64-efi --efi-directory=/mnt/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux
sudo vim /etc/sudoers
