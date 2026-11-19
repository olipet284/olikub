#!/bin/bash

APP_NAME="Doom Emacs"
APP_DESCRIPTION="Emacs framework with a curated package set"
APP_DEFAULT=0
APP_BIN=emacs

app_installed() {
  has_command emacs && [[ -d "$HOME/.config/emacs" || -d "$HOME/.config/doom" ]]
}

app_install() {
  sudo apt-get install -y emacs
  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  ~/.config/emacs/bin/doom install
}

app_uninstall() {
  apt_remove "$APP_NAME" emacs emacs-gtk
  echo "Kept Doom configuration in ~/.config/emacs and ~/.config/doom."
}
