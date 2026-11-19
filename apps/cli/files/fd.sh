#!/bin/bash

APP_NAME="fd"
APP_DESCRIPTION="Fast alternative to find"
APP_DEFAULT=1
APP_BIN=fd

app_installed() {
  has_command fd || has_command fdfind || dpkg_installed fd-find
}

app_install() {
  sudo apt-get install -y fd-find
}

app_uninstall() {
  apt_remove "$APP_NAME" fd-find
}
