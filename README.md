# Automated Arch Install for Basic barebones install

#prompts: device name,root size, swap size, username, root password, user password                                                                                    
#Packages installed: yay,NetworkManager,openssh,sudo

#how to run installer:

sudo pacman -Sy && sudo pacman -S git
git clone https://github.com/virtiz/archinstaller
cd archinstaller
./run.sh
