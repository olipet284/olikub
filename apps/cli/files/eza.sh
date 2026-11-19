#!/bin/bash

APP_NAME="eza"
APP_DESCRIPTION="Modern replacement for ls"
APP_DEFAULT=1
APP_BIN=eza

app_installed() {
  has_command eza || dpkg_installed eza
}

app_install() {
  sudo apt-get install -y eza
}

app_uninstall() {
  apt_remove "$APP_NAME" eza
}
