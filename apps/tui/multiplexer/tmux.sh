#!/bin/bash

APP_NAME="tmux"
APP_DESCRIPTION="Terminal multiplexer"
APP_DEFAULT=1
APP_BIN=tmux

app_installed() {
  has_command tmux || dpkg_installed tmux
}

app_install() {
  sudo apt-get install -y tmux
}

app_uninstall() {
  apt_remove "$APP_NAME" tmux
}
