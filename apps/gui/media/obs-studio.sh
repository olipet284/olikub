#!/bin/bash

APP_NAME="OBS Studio"
APP_DESCRIPTION="Record screencasts with display and webcam"
APP_DEFAULT=0
APP_BIN=obs

app_installed() {
  dpkg_installed obs-studio || has_command obs
}

app_install() {
  sudo apt-get install -y obs-studio
}

app_uninstall() {
  apt_remove "$APP_NAME" obs-studio
}
