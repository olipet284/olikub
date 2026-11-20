#!/bin/bash

APP_NAME="LazyDocker"
APP_DESCRIPTION="Terminal UI for Docker"
APP_DEFAULT=1
APP_BIN=lazydocker

app_installed() {
  [[ -x /usr/local/bin/lazydocker ]] || has_command lazydocker
}

app_install() {
  cd /tmp
  LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -sLo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
  tar -xf lazydocker.tar.gz lazydocker
  sudo install lazydocker /usr/local/bin
  rm lazydocker.tar.gz lazydocker
  cd -
}

app_uninstall() {
  remove_local_binary "$APP_NAME" /usr/local/bin/lazydocker
}
