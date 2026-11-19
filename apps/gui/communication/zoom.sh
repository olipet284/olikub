#!/bin/bash

APP_NAME="Zoom"
APP_DESCRIPTION="Video meetings"
APP_DEFAULT=0
APP_BIN=zoom

app_installed() {
  dpkg_installed zoom || has_command zoom
}

app_install() {
  cd /tmp
  wget https://zoom.us/client/latest/zoom_amd64.deb
  sudo apt-get install -y ./zoom_amd64.deb
  rm zoom_amd64.deb
  cd -
}

app_uninstall() {
  apt_remove "$APP_NAME" zoom
}
