#!/bin/bash

APP_NAME="git-absorb"
APP_DESCRIPTION="Automatic git commit --fixup"
APP_DEFAULT=0
APP_BIN=git-absorb

app_installed() {
  has_command git-absorb || dpkg_installed git-absorb
}

app_install() {
  sudo apt-get install -y git-absorb
}

app_uninstall() {
  apt_remove "$APP_NAME" git-absorb
}
