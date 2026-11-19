#!/bin/bash

APP_NAME="Flameshot"
APP_DESCRIPTION="Screenshot tool"
APP_DEFAULT=1
APP_BIN=flameshot

app_installed() {
  has_command flameshot || dpkg_installed flameshot
}

app_install() {
  sudo apt-get install -y flameshot
}

app_uninstall() {
  apt_remove "$APP_NAME" flameshot
}
