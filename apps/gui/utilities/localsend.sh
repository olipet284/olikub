#!/bin/bash

APP_NAME="LocalSend"
APP_DESCRIPTION="Share files with nearby devices"
APP_DEFAULT=1
APP_BIN=localsend

app_installed() {
  dpkg_installed localsend || has_command localsend
}

app_install() {
  cd /tmp
  LOCALSEND_VERSION=$(curl -s "https://api.github.com/repos/localsend/localsend/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  wget -O localsend.deb "https://github.com/localsend/localsend/releases/latest/download/LocalSend-${LOCALSEND_VERSION}-linux-x86-64.deb"
  sudo apt-get install -y ./localsend.deb
  rm localsend.deb
  cd -
}

app_uninstall() {
  apt_remove "$APP_NAME" localsend
}
