#!/bin/bash

APP_NAME="Brave"
APP_DESCRIPTION="Chrome-based browser with built-in ad blocking"
APP_DEFAULT=1
APP_BIN=brave-browser

app_installed() {
  dpkg_installed brave-browser || has_command brave-browser
}

app_install() {
  if [ ! -f /etc/apt/sources.list.d/brave-browser-release.list ]; then
    [ -f /usr/share/keyrings/brave-browser-archive-keyring.gpg ] && sudo rm /usr/share/keyrings/brave-browser-archive-keyring.gpg
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  fi

  sudo apt-get update
  sudo apt-get install -y brave-browser
}

app_uninstall() {
  apt_remove "$APP_NAME" brave-browser
  sudo rm -f /etc/apt/sources.list.d/brave-browser-release.list /usr/share/keyrings/brave-browser-archive-keyring.gpg
}
