# Automated Arch Install for Basic barebones install

//Actions:

#Partition drive, add needed packages, Create user account, install Grub bootloader

#Run fdisk-l before starting to get your device name

#run the following on a brand new Arch-Linux LIVECD boot.

sudo pacman -Sy git

git clone https://github.com/virtiz/Arch.git

cd Arch

./Main-Script.sh

#After Script1 completes run Script2 

./Build-Script2.sh
