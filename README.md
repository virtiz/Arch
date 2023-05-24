# Automated Arch Install for vanilla Arch
#This was for testing and not recommended to be used

#prompts: device name,root size, swap size, username, root password, user password                                                                                    
#Packages installed: yay,NetworkManager,openssh,sudo

##how to run the installer##

sudo pacman -Sy && sudo pacman -S git

git clone https://github.com/virtiz/archinstaller

cd archinstaller

./run.sh
