#!/bin/bash

APP_NAME="fzf"
APP_DESCRIPTION="Command-line fuzzy finder"
APP_DEFAULT=1
APP_BIN=fzf

app_installed() {
  has_command fzf || dpkg_installed fzf
}

app_install() {
  sudo apt-get install -y fzf
}

app_uninstall() {
  apt_remove "$APP_NAME" fzf
}
