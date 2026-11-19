#!/bin/bash

APP_NAME="wl-clipboard"
APP_DESCRIPTION="System clipboard interface for Wayland"
APP_DEFAULT=1
APP_BIN=wl-copy

app_installed() {
  has_command wl-copy || dpkg_installed wl-clipboard
}

app_install() {
  sudo apt-get install -y wl-clipboard
}

app_uninstall() {
  apt_remove "$APP_NAME" wl-clipboard
}
