#!/bin/bash

# Configure the bash shell using Olikub defaults
[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/olikub"
printf '%s\n' "$OLIKUB_PATH" > "${XDG_CONFIG_HOME:-$HOME/.config}/olikub/path"
cp "$OLIKUB_PATH/configs/bashrc" ~/.bashrc
mkdir -p ~/dotfiles/bash

# Load the PATH for use later in the installers
source "$OLIKUB_PATH/defaults/bash/shell"

[ -f ~/.inputrc ] && mv ~/.inputrc ~/.inputrc.bak
# Configure the inputrc using Olikub defaults
cp "$OLIKUB_PATH/defaults/bash/inputrc" ~/.inputrc
