#!/bin/bash

# Run this script after the base system is installed. See ./bootstrap.sh

PKG=pkg # Package lists
AUR=aur

sudo pacman -S --needed  $(<$PKG)

# Build yay AUR helper 
mkdir -p ~/git && git clone https://aur.archlinux.org/yay.git
mkdir -p ~/git/yay && makepkg -si
yay -S --needed $(<$AUR)

npm install -g gtop
npm install -g vtop

#pip3 install --user keystone unicorn capstone ropper pynvim kaggle websocket-client
pip3 install --user pynvim kaggle websocket-client

nvim +PlugInstall +qall # NeoViM Plugins
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" # Oh-my-zsh
pacman -Sy --noconfirm zsh-theme-powerlevel10k # P10k
#echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc

newgrp docker # For docker
sudo usermod -aG docker jmd
sudo systemctl enable docker
sudo systemctl enable org.cups.cupsd.service 
sudo systemctl enable bluetooth
