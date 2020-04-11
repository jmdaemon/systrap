#!/bin/bash

# This script is intended to be run during/after initial installation 

PKG=pkg
AUR=aur
# AUR=$HOME/aur
# Install all our packages

# Parse *.pkg.list
sudo pacman -S --needed  $(<$PKG)
sudo pacman -S --needed  $(<$LAP)

# Parse .csv file
#while IFS=, read -r field2
#do : sudo pacman -S --needed "$field2"
#done < input.csv

# Build yay AUR helper 
mkdir -p ~/git && git clone https://aur.archlinux.org/yay.git
mkdir -p ~/git/yay && makepkg -si
yay -S --needed $(<$AUR)

npm install -g gtop
npm install -g vtop

#pip3 install --user keystone unicorn capstone ropper pynvim kaggle websocket-client
pip3 install --user pynvim kaggle websocket-client

nvim +PlugInstall +qall # NeoViM Plugins

# Oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# P10k
pacman -Sy --noconfirm zsh-theme-powerlevel10k
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc

newgrp docker
sudo usermod -aG docker jmd
sudo systemctl enable docker
sudo systemctl enable org.cups.cupsd.service 
sudo systemctl enable bluetooth
