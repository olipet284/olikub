#!/bin/bash

APP_NAME="Kitty"
APP_DESCRIPTION="Fast terminal emulator"
APP_DEFAULT=1
APP_BIN=kitty

app_installed() {
  has_command kitty || dpkg_installed kitty
}

app_install() {
  sudo apt-get install -y kitty
}

app_uninstall() {
  apt_remove "$APP_NAME" kitty
}
