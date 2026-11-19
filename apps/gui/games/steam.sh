#!/bin/bash

APP_NAME="Steam"
APP_DESCRIPTION="Game store and launcher"
APP_DEFAULT=0
APP_BIN=steam

app_installed() {
  has_command steam || dpkg_installed steam-launcher || dpkg_installed steam
}

app_install() {
  cd /tmp
  wget https://cdn.akamai.steamstatic.com/client/installer/steam.deb
  sudo apt-get install -y ./steam.deb
  rm steam.deb
  cd -
}

app_uninstall() {
  apt_remove "$APP_NAME" steam steam-launcher
}
