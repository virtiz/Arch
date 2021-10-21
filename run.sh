#!/bin/sh -e

######Define Vairables#####

##Set Defaults
device = "/dev/vda"
rootsz = "15"
swapsz = "5"
lang="en_US.UTF-8"
locale = "America/Phoenix"
username = "owner"
hostname = "arch-build"
fdisk -l
echo -n "Enter disk name to install Arch on, Press enter for default (/dev/vda): "
read device
echo -n "Enter partition size for Root, Press enter for default (15): "
read rootsz
echo -n "Size of Swap? press enter for default (5):  "
read swapsz
#this line is a test-delete it
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
echo "partitions created"
lvmpart=`sudo fdisk -l $device | grep LVM | awk '{print $1}'`
efipart=`sudo fdisk -l $device | grep EFI | awk '{print $1}'`
bootpart=`sudo fdisk -l $device | grep filesystem | awk '{print $1}'`
mkfs.fat -F32 $efipart
mkfs.ext2 $bootpart
pvcreate -ff $lvmpart
vgcreate lvm $lvmpart
lvcreate -n root -L $rootsz"G" lvm
lvcreate -n swap -L $swapsz"G" lvm
lvcreate -n home -l 100%FREE lvm
mkfs.btrfs -L root /dev/lvm/root
mkfs.btrfs -L home /dev/lvm/home
mkswap /dev/lvm/swap
swapon /dev/lvm/swap
mount /dev/lvm/root /mnt
mkdir /mnt/{home,boot}
mount $bootpart /mnt/boot
mkdir /mnt/boot/efi
mount $efipart /mnt/boot/efi
mount /dev/lvm/home /mnt/home

####Setup Configs####
pacstrap /mnt base base-devel linux linux-firmware grub efibootmgr vim btrfs-progs --noconfirm
genfstab -U -p /mnt > /mnt/etc/fstab

#Function Buildout
Buildout(){
#Add multilib mirrors
sed -i '93s/^#//' /etc/pacman.conf
sed -i '94s/^#//' /etc/pacman.conf

#Ask Questions
echo -n "Enter Username, Press enter for Default (owner):  "
read username
echo -n "Enter HostName, Press enter for Default (Arch-build): "
read hostname
echo -n "Enter locale, Press enter for default (America/Phoenix): "
read locale


#Set user preferences
echo $hostname > /etc/hostname
ln -s /usr/share/zoneinfo/$locale /etc/localtime
echo "LANG=$lang" >> /etc/locale.conf
sed -i '177s/^#//' /etc/locale.gen
locale-gen
hwclock --systohc

#Set Passwords
echo "Enter root password: "
passwd root
useradd -m -g users -G wheel $username
echo "Enter "$username" password: "
passwd $username

#Install base software packages
sudo pacman -Sy && sudo pacman -S networkmanager lvm2 sudo openssh git cifs-utils --noconfirm

#Correct hooks to add lvm2
sed -i '/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/ i HOOKS=(base udev autodetect modconf block lvm2 filesystems keyboard fsck)' /etc/mkinitcpio.conf
sed -i '/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/ d' /etc/mkinitcpio.conf
#Grub install
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux

#Give users access in sudoers
sed -i '/^# %wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers
sed -i "/root ALL=(ALL)/ i $username ALL=(ALL) ALL" /etc/sudoers

#Enable Services
systemctl enable {sshd,NetworkManager}

#install packages for user
#yay install
git clone https://aur.archlinux.org/yay.git
chmod 777 yay
cd yay
sudo -u $username makepkg -si --noconfirm

}

export -f Buildout
arch-chroot /mnt /bin/bash -c "Buildout"

#cleanup and say goodbye
clear
echo "yay,openssh,git,NetworkManager have been insalled. You may reboot now"
echo "would you like to install a Desktop Environment? after rebooting launch ./nextsteps"


#Future NOTES
#create the DE and start apps scripts and move them to the /home/$username/
#echo "to install the starter pack run ./starter" && echo "includes: neovim,rofi,brave,zsh,kitty,discord,steam"
#echo "to install DE run ./plasma ./i3 ./gnome respectively. If you install i3 we recommend installing DE first"
