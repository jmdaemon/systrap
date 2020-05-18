#!/bin/bash

PKG=pkg # Packages
DLP=dlp # DL Packages and Libraries

SWIFT="swift" # Conda environment name

sys=ubuntu-workstation # Current system configuration

PPA=(
    ppa:apt-fast/stable 
    ppa:graphics-drivers/ppa
)

FASTAI=(
    fastai.git
    fastprogress.git
    fastec2.git
    course-v3.git
    fastai_docs.git
)

# WIP
install_ppa() {
    for i in ${!PPA[@]}; do
        if ! grep -q "^deb .*${PPA[$i]}" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
            sudo add-apt-repository -y ${PPA[$i]}
        fi
    done
}

install_ppa
sudo apt update
sudo apt install -y apt-fast upgrade

cat $DLP | xargs sudo apt install -y # Install DL Libraries
cat $PKG | xargs sudo apt install -y # Install packages for our workstation

# Install basics: desktop environment, and login-manager 
sudo apt-fast install -y xfce4 xfce4-goodies xorg lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings zsh tmux fortune-mod cowsay

sudo snap install hub --classic # Hub is a git wrapper - https://hub.github.com/

# Configure system
git clone https://gitlab.com/JMD_/systrap ~/.systrap -b $sys
git clone --bare https://gitlab.com/JMD_/dotfiles $HOME/.cfg -b $sys
git submodule add -f https://gitlab.com/JMD_/backgrounds ~/backgrounds

config() {
    /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

mkdir -p ~/.config-backup
config checkout $sys
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
config checkout $sys
config config status.showUntrackedFiles no

# Drivers
ubuntu-drivers devices
sudo apt-fast install -y nvidia-driver-440
sudo modprobe nvidia
nvidia-smi

# Must do something janky to install gcc-6
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6   40 --slave /usr/bin/g++ g++ /usr/bin/g++-6 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-6
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7   40 --slave /usr/bin/g++ g++ /usr/bin/g++-7 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-7

# Cuda
mkdir -p ~/download
cd ~/download
wget http://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda_10.2.89_440.33.01_linux.run
chmod u+x cuda_1*_linux*
sudo ./cuda_*_linux.run --silent --toolkit
echo /usr/local/cuda/lib64 | sudo tee -a /etc/ld.so.conf
sudo ldconfig

# Cudnn
cd ~/download
wget http://files.fast.ai/files/cudnn-10.2-linux-x64-v7.6.5.32.tgz
tar xf cudnn-10*.tgz
sudo cp cuda/include/cudnn.h /usr/local/cuda/include
sudo cp -P cuda/lib64/libcudnn* /usr/local/cuda/lib64
sudo chmod a+r /usr/local/cuda/include/cudnn.h /usr/local/cuda/lib64/libcudnn*
sudo ldconfig

# Fastai Repos
mkdir -p ~/git && cd ~/git  
for i in ${!FASTAI[@]}; do  
    git clone https://github.com/fastai/${PPA[$i]}
done

conda install -c pytorch -c fastai fastai pytorch

pip install jupyter_contrib_nbextensions

jupyter notebook --generate-config
cat << 'EOF' >> ~/.jupyter/jupyter_notebook_config.py
c.NotebookApp.open_browser = False
#c.NotebookApp.token = ''
EOF
jupyter contrib nbextension install --user
jupyter nbextension enable collapsible_headings/main
mkdir ~/.jupyter/custom
echo '.container { width: 99% !important; }' > ~/.jupyter/custom/custom.css

cd ~/download/
wget https://storage.googleapis.com/swift-tensorflow-artifacts/releases/v0.8/rc1/swift-tensorflow-RELEASE-0.8-cuda10.1-cudnn7-ubuntu18.04.tar.gz
sudo apt-fast -y install git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev libncurses5-dev pkg-config libblocksruntime-dev libcurl4-openssl-dev systemtap-sdt-dev tzdata rsync
tar xf swift-tensorflow-RELEASE-0.8-cuda10.1-cudnn7-ubuntu18.04.tar.gz

# Optionally - Use nightly builds instead
#wget https://storage.googleapis.com/swift-tensorflow-artifacts/nightlies/latest/swift-tensorflow-DEVELOPMENT-cuda10.1-cudnn7-ubuntu18.04.tar.gz
#tar xf swift-tensorflow-RELEASE-0.8-cuda10.1-cudnn7-ubuntu18.04.tar.gz
mkdir ~/swift && cd swift
mv ~/download/usr ./

cd ~/git
git clone https://github.com/google/swift-jupyter.git
cd swift-jupyter
conda activate $swift
python register.py --sys-prefix --swift-python-use-conda --use-conda-shared-libs   --swift-toolchain ~/swift

cd fastai_docs/
jupyter notebook

# Configure clock for local time zone (Canada/Pacific)
sudo timedatectl set-timezone Canada/Pacific

## Nerd Fonts
cd ~/git/
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts # Shallow Clone
cd nerd-fonts && ./install.sh
