#!/bin/bash

# Configure system
git clone https://gitlab.com/JMD_/systrap ~/.systrap -b $sys
git clone --bare https://gitlab.com/JMD_/dotfiles $HOME/.cfg -b $sys
git submodule add -f https://gitlab.com/JMD_/backgrounds ~/backgrounds

function config {
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
