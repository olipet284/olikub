#!/bin/bash

APP_NAME="LazyGit"
APP_DESCRIPTION="Terminal UI for git"
APP_DEFAULT=1
APP_BIN=lazygit

app_installed() {
  [[ -x /usr/local/bin/lazygit ]] || has_command lazygit
}

app_install() {
  cd /tmp
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -sLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar -xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm lazygit.tar.gz lazygit
  mkdir -p ~/.config/lazygit/
  touch ~/.config/lazygit/config.yml
  cd -
}

app_uninstall() {
  remove_local_binary "$APP_NAME" /usr/local/bin/lazygit
}
