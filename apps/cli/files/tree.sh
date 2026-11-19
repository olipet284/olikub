#!/bin/bash

APP_NAME="tree"
APP_DESCRIPTION="Display directories as a tree"
APP_DEFAULT=1
APP_BIN=tree

app_installed() {
  has_command tree || dpkg_installed tree
}

app_install() {
  sudo apt-get install -y tree
}

app_uninstall() {
  apt_remove "$APP_NAME" tree
}
