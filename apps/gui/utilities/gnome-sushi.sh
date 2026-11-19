#!/bin/bash

APP_NAME="GNOME Sushi"
APP_DESCRIPTION="Quick file previews in the file manager"
APP_DEFAULT=1

app_installed() {
  dpkg_installed gnome-sushi
}

app_install() {
  sudo apt-get install -y gnome-sushi
}

app_uninstall() {
  apt_remove "$APP_NAME" gnome-sushi
}
