#!/bin/bash

# Install apt-fast
sudo add-apt-repository -y ppa:apt-fast/stable
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt-get update
sudo apt-get -y install apt-fast
# prompts

sudo apt-fast -y upgrade

# Install DL Libraries
sudo apt-fast install -y python3-pip ubuntu-drivers-common libvorbis-dev libflac-dev libsndfile-dev cmake build-essential libgflags-dev libgoogle-glog-dev libgtest-dev google-mock zlib1g-dev libeigen3-dev libboost-all-dev libasound2-dev libogg-dev libtool libfftw3-dev libbz2-dev liblzma-dev libgoogle-glog0v5 gcc-6 gfortran-6 g++-6 doxygen graphviz libsox-fmt-all parallel exuberant-ctags vim-nox python-powerline python3-pip ack lsyncd
sudo apt-fast install -y tigervnc-standalone-server firefox mesa-common-dev

cat << 'EOF' >> ~/.ssh/config
Host *
ServerAliveInterval 60
StrictHostKeyChecking no
Host github.com
User git
Port 22
Hostname github.com
TCPKeepAlive yes
IdentitiesOnly yes
EOF
chmod 600 ~/.ssh/config

# Get dotfiles and configs
git clone https://gitlab.com/JMD_/systrap ~/.systrap -b ubuntu-workstation
git clone --bare https://gitlab.com/JMD_/dotfiles $HOME/.cfg -b ubuntu-workstation
git submodule add -f https://gitlab.com/JMD_/backgrounds ~/backgrounds
function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}
mkdir -p .config-backup
config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
config checkout
config config status.showUntrackedFiles no


pip3 install powerline-status

# Drivers
ubuntu-drivers devices
sudo apt-fast install -y nvidia-driver-440
sudo modprobe nvidia
nvidia-smi

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6   40 --slave /usr/bin/g++ g++ /usr/bin/g++-6 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-6
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7   40 --slave /usr/bin/g++ g++ /usr/bin/g++-7 --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-7

# Install desktop environment, and login-manager 
sudo apt-fast install -y xfce4 xfce4-goodies xorg lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings zsh tmux fortune-mod cowsay

# Cuda
mkdir -p ~/download
cd ~/download
wget http://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda_10.2.89_440.33.01_linux.run
chmod u+x cuda_1*_linux*
# sudo ./cuda_*_linux.run --silent --toolkit --driver
sudo ./cuda_*_linux.run --silent --toolkit
echo /usr/local/cuda/lib64 | sudo tee -a /etc/ld.so.conf
sudo ldconfig
#echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
#source ~/.bashrc

# Cudnn
cd ~/download
wget http://files.fast.ai/files/cudnn-10.2-linux-x64-v7.6.5.32.tgz
tar xf cudnn-10*.tgz
sudo cp cuda/include/cudnn.h /usr/local/cuda/include
sudo cp -P cuda/lib64/libcudnn* /usr/local/cuda/lib64
sudo chmod a+r /usr/local/cuda/include/cudnn.h /usr/local/cuda/lib64/libcudnn*
sudo ldconfig

# Fastai Repos
cd
mkdir -p ~/git
cd ~/git
git clone https://github.com/fastai/fastai.git &
git clone https://github.com/fastai/fastprogress.git &
git clone https://github.com/fastai/fastec2.git &
git clone https://github.com/fastai/course-v3.git

sudo snap install hub --classic


# Add to ~/.zshrc, .bashrc
#cat << 'EOF' >> ~/.bashrc
#alias git=hub
#alias gpr='git pull-request -m "$(git log -1 --pretty=%B)"'
#clonefork() {
#hub clone "$1"
#cd "${1##*/}"
#hub fork
#}
#EOF
#source ~/.bashrc

conda install -c pytorch -c fastai fastai pytorch

# This section is just if you want to run fastai & fastprogress from master
# Add to ~/.zshrc, .bashrc
#cd ~/git
#conda uninstall -y fastai fastprogress
#cd fastai
#pip install -e .
#cd ../fastprogress
#pip install -e .


#pip install jupyter_contrib_nbextensions
pip3 install jupyter_contrib_nbextensions

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
cd
mkdir swift
cd swift
mv ~/download/usr ./
cd
#echo 'export PATH=~/swift/usr/bin:$PATH' >> ~/.bashrc
#source ~/.bashrc

cd ~/git
git clone https://github.com/google/swift-jupyter.git
cd swift-jupyter
# conda activate {env}
python register.py --sys-prefix --swift-python-use-conda --use-conda-shared-libs   --swift-toolchain ~/swift

cd ~/git
git clone https://github.com/fastai/fastai_docs.git
cd fastai_docs/
jupyter notebook

# Timedatectl
sudo timedatectl set-timezone Canada/Pacific

# Nerd Fonts
cd ~/git/
# git clone https://github.com/ryanoasis/nerd-fonts
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts
cd nerd-fonts 
./install.sh
