#!/bin/bash

APP_NAME="GNOME Tweaks"
APP_DESCRIPTION="Tune GNOME desktop settings"
APP_DEFAULT=1
APP_BIN=gnome-tweaks

app_installed() {
  dpkg_installed gnome-tweak-tool || dpkg_installed gnome-tweaks || has_command gnome-tweaks
}

app_install() {
  sudo apt-get install -y gnome-tweak-tool
}

app_uninstall() {
  apt_remove "$APP_NAME" gnome-tweak-tool gnome-tweaks
}
