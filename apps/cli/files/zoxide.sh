#!/bin/bash

APP_NAME="zoxide"
APP_DESCRIPTION="Smarter cd command"
APP_DEFAULT=1
APP_BIN=zoxide

app_installed() {
  has_command zoxide || dpkg_installed zoxide
}

app_install() {
  sudo apt-get install -y zoxide
}

app_uninstall() {
  apt_remove "$APP_NAME" zoxide
}
