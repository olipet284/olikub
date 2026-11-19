#!/bin/bash

APP_NAME="1Password"
APP_DESCRIPTION="Password manager and CLI"
APP_DEFAULT=0
APP_BIN=1password

app_installed() {
  dpkg_installed 1password || dpkg_installed 1password-cli || has_command 1password
}

app_install() {
  cd /tmp
  wget https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb -O 1password.deb
  sudo apt-get install -y ./1password.deb
  rm 1password.deb
  cd -
}

app_uninstall() {
  apt_remove "$APP_NAME" 1password 1password-cli
  sudo rm -f /etc/apt/sources.list.d/1password.list
  sudo rm -f /usr/share/keyrings/1password-archive-keyring.gpg
  sudo rm -f /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
  sudo rm -rf /etc/debsig/policies/AC2D62742012EA22
}
