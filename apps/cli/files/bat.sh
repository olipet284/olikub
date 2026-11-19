#!/bin/bash

APP_NAME="bat"
APP_DESCRIPTION="Cat clone with syntax highlighting"
APP_DEFAULT=1
APP_BIN=bat

app_installed() {
  has_command bat || has_command batcat || dpkg_installed bat
}

app_install() {
  sudo apt-get install -y bat
}

app_uninstall() {
  apt_remove "$APP_NAME" bat
}
