#!/bin/bash

APP_NAME="BleachBit"
APP_DESCRIPTION="System cleaner"
APP_DEFAULT=1
APP_BIN=bleachbit

app_installed() {
  has_command bleachbit || dpkg_installed bleachbit
}

app_install() {
  sudo apt-get install -y bleachbit
}

app_uninstall() {
  apt_remove "$APP_NAME" bleachbit
}
