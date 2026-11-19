#!/bin/bash

APP_NAME="GitHub CLI"
APP_DESCRIPTION="GitHub from the command line"
APP_DEFAULT=1
APP_BIN=gh

app_installed() {
  has_command gh || dpkg_installed gh
}

app_install() {
  if [ ! -f /etc/apt/sources.list.d/github-cli.list ]; then
    [ -f /usr/share/keyrings/githubcli-archive-keyring.gpg ] && sudo rm /usr/share/keyrings/githubcli-archive-keyring.gpg
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg status=none
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  fi

  sudo apt-get update
  sudo apt-get install -y gh
}

app_uninstall() {
  apt_remove "$APP_NAME" gh
  sudo rm -f /etc/apt/sources.list.d/github-cli.list /usr/share/keyrings/githubcli-archive-keyring.gpg
}
