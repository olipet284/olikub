#!/bin/bash

APP_NAME="MarkText"
APP_DESCRIPTION="Markdown editor"
APP_DEFAULT=1
APP_BIN=marktext

app_installed() {
  dpkg_installed marktext || has_command marktext
}

app_install() {
  cd /tmp
  wget -O marktext.deb "https://github.com/marktext/marktext/releases/download/v0.17.1/marktext-amd64.deb"
  sudo apt-get install -y ./marktext.deb
  rm marktext.deb
  cd -
}

app_uninstall() {
  apt_remove "$APP_NAME" marktext
}
