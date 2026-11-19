#!/bin/bash

APP_NAME="VLC"
APP_DESCRIPTION="Media player"
APP_DEFAULT=1
APP_BIN=vlc

app_installed() {
  has_command vlc || dpkg_installed vlc
}

app_install() {
  sudo apt-get install -y vlc
}

app_uninstall() {
  apt_remove "$APP_NAME" vlc
}
