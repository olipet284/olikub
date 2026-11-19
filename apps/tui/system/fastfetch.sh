#!/bin/bash

APP_NAME="Fastfetch"
APP_DESCRIPTION="Display system information in the terminal"
APP_DEFAULT=1
APP_BIN=fastfetch

app_installed() {
  has_command fastfetch || dpkg_installed fastfetch
}

app_install() {
  sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
  sudo apt-get update -y
  sudo apt-get install -y fastfetch

  if [ ! -f "$HOME/.config/fastfetch/config.jsonc" ]; then
    mkdir -p ~/.config/fastfetch
    cp "$OLIKUB_PATH/configs/fastfetch.jsonc" ~/.config/fastfetch/config.jsonc
  fi
}

app_uninstall() {
  apt_remove "$APP_NAME" fastfetch
}
