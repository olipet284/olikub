#!/bin/bash

APP_NAME="Ghostty"
APP_DESCRIPTION="Fast GPU-accelerated terminal"
APP_DEFAULT=1
APP_BIN=ghostty

app_installed() {
  has_command ghostty || dpkg_installed ghostty
}

app_install() {
  sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
  sudo apt-get install -y ghostty
}

app_uninstall() {
  apt_remove "$APP_NAME" ghostty
}
