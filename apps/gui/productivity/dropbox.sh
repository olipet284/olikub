#!/bin/bash

APP_NAME="Dropbox"
APP_DESCRIPTION="Sync files across machines"
APP_DEFAULT=0

app_installed() {
  dpkg_installed nautilus-dropbox
}

app_install() {
  sudo apt-get install -y nautilus-dropbox >/dev/null
}

app_uninstall() {
  apt_remove "$APP_NAME" nautilus-dropbox
}
