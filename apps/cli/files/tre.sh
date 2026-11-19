#!/bin/bash

APP_NAME="tre"
APP_DESCRIPTION="Tree view that respects .gitignore"
APP_DEFAULT=1
APP_BIN=tre

app_installed() {
  has_command tre || dpkg_installed tre-command
}

app_install() {
  sudo apt-get install -y tre-command
}

app_uninstall() {
  apt_remove "$APP_NAME" tre-command
}
