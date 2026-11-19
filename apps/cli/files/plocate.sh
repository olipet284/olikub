#!/bin/bash

APP_NAME="plocate"
APP_DESCRIPTION="Fast file location database"
APP_DEFAULT=1
APP_BIN=plocate

app_installed() {
  has_command plocate || has_command locate || dpkg_installed plocate
}

app_install() {
  sudo apt-get install -y plocate
}

app_uninstall() {
  apt_remove "$APP_NAME" plocate
}
