#!/bin/bash

APP_NAME="Sublime Text"
APP_DESCRIPTION="Sophisticated text editor"
APP_DEFAULT=0
APP_BIN=subl

app_installed() {
  has_command subl || dpkg_installed sublime-text
}

app_install() {
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg |
    sudo tee /etc/apt/keyrings/sublimehq-pub.asc >/dev/null
  echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' |
    sudo tee /etc/apt/sources.list.d/sublime-text.sources >/dev/null

  sudo apt-get update
  sudo apt-get install -y sublime-text
}

app_uninstall() {
  apt_remove "$APP_NAME" sublime-text
  sudo rm -f /etc/apt/sources.list.d/sublime-text.sources /etc/apt/keyrings/sublimehq-pub.asc
}
