#!/bin/bash

APP_NAME="Codex desktop"
APP_DESCRIPTION="OpenAI Codex in the ChatGPT desktop app"
APP_DEFAULT=0
APP_BIN=chatgpt

app_installed() {
  dpkg_installed chatgpt || has_command chatgpt || desktop_file_exists chatgpt.desktop
}

app_install() {
  cd /tmp
  wget https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb -O chatgpt.deb
  sudo apt-get install -y ./chatgpt.deb
  rm chatgpt.deb
  cd -
}

app_uninstall() {
  apt_remove "$APP_NAME" chatgpt
  echo "Kept ChatGPT user data in ~/.config and ~/.local/share."
}
