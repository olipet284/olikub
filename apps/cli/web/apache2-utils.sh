#!/bin/bash

APP_NAME="apache2-utils"
APP_DESCRIPTION="Apache utilities such as htpasswd"
APP_DEFAULT=1

app_installed() {
  dpkg_installed apache2-utils
}

app_install() {
  sudo apt-get install -y apache2-utils
}

app_uninstall() {
  apt_remove "$APP_NAME" apache2-utils
}
