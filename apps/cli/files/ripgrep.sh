#!/bin/bash

APP_NAME="ripgrep"
APP_DESCRIPTION="Fast recursive search tool"
APP_DEFAULT=1
APP_BIN=rg

app_installed() {
  has_command rg || dpkg_installed ripgrep
}

app_install() {
  sudo apt-get install -y ripgrep
}

app_uninstall() {
  apt_remove "$APP_NAME" ripgrep
}
