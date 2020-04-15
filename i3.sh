#!/bin/bash

mkdir ~/git/i3/
cd ~/git/i3/

# i3-gaps - TWM
# - - - - - - - - - - - - - - - - - - - - - -
sudo apt-fast install -y libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf xutils-dev libtool libxcb-shape0-dev
cd /tmp
git clone https://www.github.com/Airblader/i3 i3-gaps
cd i3-gaps
git checkout gaps && git pull
autoreconf --force --install
rm -rf build
mkdir build
cd build
../configure --prefix=/usr --sysconfdir=/etc
make
sudo make install

## Extras
echo "Installing extras for i3-gaps"
sudo apt-fast install -y wget ranger mediainfo highlight tmux calcurse qutebrowser imagemagick transmission-cli pinta markdown audacity rsync syncthing cups unzip unrar biber ntfs-3g zip

cd ~/git/i3/
# Picom - Compositor
# - - - - - - - - - - - - - - - - - - - - - -
sudo apt-fast -y install libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev  libpcre2-dev  libevdev-dev uthash-dev libev-dev libx11-xcb-dev asciidoc

git clone https://github.com/yshui/picom
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
ninja -C build install

cd ~/git/i3/
# Polybar - Status Bar
# - - - - - - - - - - - - - - - - - - - - - -
sudo apt-fast install -y build-essential git cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev

sudo apt-fast install -y libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev i3-wm libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev libnl-genl-3-dev

# Make sure to type the `git' command as is to clone all git submodules too
git clone --recursive https://github.com/polybar/polybar
cd polybar

mkdir build
cd build
# cmake ..
cmake -DCMAKE_CXX_COMPILER="clang++" ..
make -j$(nproc)
# Optional. This will install the polybar executable in /usr/local/bin
sudo make install

# Rofi - Dmenu Alternative
# - - - - - - - - - - - - - - - - - - - - - -
# Use the PPA before building from scratch
sudo add-apt-repository ppa:jasonpleau/rofi
sudo apt update
sudo apt install rofi

cd ~/git/i3/
# Dunst - Notification Daemon
# - - - - - - - - - - - - - - - - - - - - - -
sudo apt-fast install -y libdbus-1-dev libx11-dev libxinerama-dev libxrandr-dev libxss-dev libglib2.0-dev libpango1.0-dev libgtk-3-dev libxdg-basedir-dev
git clone https://github.com/dunst-project/dunst.git
cd dunst
make -j4
sudo make install

cd ~/git/i3/
# Termite - Terminal Emulator
# - - - - - - - - - - - - - - - - - - - - - -
sudo apt update
sudo apt install build-essential
#sudo apt-get install -y git g++ libgtk-3-dev gtk-doc-tools gnutls-bin valac intltool libpcre2-dev libglib3.0-cil-dev libgnutls28-dev libgirepository1.0-dev libxml2-utils gperf
sudo apt-get install -y git libgtk-3-dev gtk-doc-tools gnutls-bin valac intltool libpcre2-dev libglib3.0-cil-dev libgnutls28-dev libgirepository1.0-dev libxml2-utils gperf

# VTE
git clone https://github.com/thestinger/vte-ng.git
echo export LIBRARY_PATH="/usr/include/gtk-3.0:$LIBRARY_PATH"
cd vte-ng
./autogen.sh
make && sudo make install


cd ~/git/i3/
git clone --recursive https://github.com/thestinger/termite.git
cd termite
make
sudo make install
sudo ldconfig
sudo mkdir -p /lib/terminfo/x
sudo ln -s /usr/local/share/terminfo/x/xterm-termite /lib/terminfo/x/xterm-termite
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/termite 60


# mpd, ncmpcpp - MPD Server, Client
sudo apt-fast install -y mpd ncmpcpp
