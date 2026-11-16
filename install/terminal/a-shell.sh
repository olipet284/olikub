#!/bin/bash

# Configure the bash shell using Olikub defaults
[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
cp ~/.local/share/olikub/configs/bashrc ~/.bashrc
mkdir -p ~/dotfiles/bash

# Load the PATH for use later in the installers
source ~/.local/share/olikub/defaults/bash/shell

[ -f ~/.inputrc ] && mv ~/.inputrc ~/.inputrc.bak
# Configure the inputrc using Olikub defaults
cp ~/.local/share/olikub/configs/inputrc ~/.inputrc
