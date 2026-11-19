#!/bin/bash

APP_NAME="Chrome"
APP_DESCRIPTION="Google Chrome browser"
APP_DEFAULT=0
APP_BIN=google-chrome-stable

app_installed() {
  dpkg_installed google-chrome-stable || has_command google-chrome-stable
}

app_install() {
  cd /tmp
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt-get install -y ./google-chrome-stable_current_amd64.deb
  rm google-chrome-stable_current_amd64.deb
  xdg-settings set default-web-browser google-chrome.desktop
  cd -
}

app_uninstall() {
  apt_remove "$APP_NAME" google-chrome-stable
}
