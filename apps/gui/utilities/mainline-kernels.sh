#!/bin/bash

APP_NAME="Mainline Kernels"
APP_DESCRIPTION="Install newer Linux kernels than the Ubuntu defaults"
APP_DEFAULT=0
APP_BIN=mainline

app_installed() {
  has_command mainline || dpkg_installed mainline
}

app_install() {
  sudo add-apt-repository -y ppa:cappelikan/ppa
  sudo apt-get update -y
  sudo apt-get install -y mainline
}

app_uninstall() {
  apt_remove "$APP_NAME" mainline
}
