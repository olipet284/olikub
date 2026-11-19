#!/bin/bash

APP_NAME="Discord"
APP_DESCRIPTION="Voice, video and text chat"
APP_DEFAULT=0
APP_BIN=discord

app_installed() {
  dpkg_installed discord || has_command discord
}

app_install() {
  cd /tmp
  wget https://discord.com/api/download?platform=linux -O discord.deb
  sudo apt-get install -y ./discord.deb
  rm discord.deb
  cd -
}

app_uninstall() {
  apt_remove "$APP_NAME" discord
}
