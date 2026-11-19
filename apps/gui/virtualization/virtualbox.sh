#!/bin/bash

APP_NAME="VirtualBox"
APP_DESCRIPTION="Run Windows and Linux virtual machines"
APP_DEFAULT=0
APP_BIN=virtualbox

app_installed() {
  has_command virtualbox || dpkg_installed virtualbox
}

app_install() {
  sudo apt-get install -y virtualbox virtualbox-ext-pack
  sudo usermod -aG vboxusers "${USER}"
}

app_uninstall() {
  apt_remove "$APP_NAME" virtualbox virtualbox-dkms virtualbox-qt virtualbox-ext-pack
  sudo apt-get autoremove --purge -y
  echo "Kept VirtualBox configuration in ~/.config/VirtualBox."
}
