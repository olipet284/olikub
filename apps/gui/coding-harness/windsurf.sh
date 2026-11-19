#!/bin/bash

APP_NAME="Windsurf"
APP_DESCRIPTION="AI-powered code editor"
APP_DEFAULT=0
APP_BIN=windsurf

app_installed() {
  has_command windsurf || dpkg_installed windsurf
}

app_install() {
  if [ ! -f /etc/apt/sources.list.d/windsurf.list ]; then
    [ -f /usr/share/keyrings/windsurf-stable-archive-keyring.gpg ] && sudo rm /usr/share/keyrings/windsurf-stable-archive-keyring.gpg
    curl -fsSL "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | sudo gpg --dearmor -o /usr/share/keyrings/windsurf-stable-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/windsurf-stable-archive-keyring.gpg arch=amd64] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | sudo tee /etc/apt/sources.list.d/windsurf.list >/dev/null
  fi

  sudo apt-get update
  sudo apt-get install -y windsurf
}

app_uninstall() {
  apt_remove "$APP_NAME" windsurf
  sudo rm -f /etc/apt/sources.list.d/windsurf.list /usr/share/keyrings/windsurf-stable-archive-keyring.gpg
}
