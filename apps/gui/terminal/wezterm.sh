#!/bin/bash

APP_NAME="WezTerm"
APP_DESCRIPTION="GPU-accelerated terminal emulator"
APP_DEFAULT=0
APP_BIN=wezterm

app_installed() {
  has_command wezterm || dpkg_installed wezterm
}

app_install() {
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' |
    sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
  sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg

  sudo apt-get update
  sudo apt-get install -y wezterm
}

app_uninstall() {
  apt_remove "$APP_NAME" wezterm
  sudo rm -f /etc/apt/sources.list.d/wezterm.list /usr/share/keyrings/wezterm-fury.gpg
}
