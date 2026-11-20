#!/bin/bash

APP_NAME="LibreWolf"
APP_DESCRIPTION="Firefox fork focused on privacy"
APP_DEFAULT=0
APP_BIN=librewolf

app_installed() {
  dpkg_installed librewolf || has_command librewolf
}

app_install() {
  sudo apt-get install -y extrepo
  sudo extrepo enable librewolf
  sudo apt-get update
  sudo apt-get install -y librewolf
}

app_uninstall() {
  apt_remove "$APP_NAME" librewolf
  sudo extrepo disable librewolf 2>/dev/null || true
}
