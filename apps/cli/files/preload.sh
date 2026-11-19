#!/bin/bash

APP_NAME="preload"
APP_DESCRIPTION="Adaptive readahead daemon"
APP_DEFAULT=1

app_installed() {
  dpkg_installed preload
}

app_install() {
  sudo apt-get install -y preload
}

app_uninstall() {
  apt_remove "$APP_NAME" preload
}
