#!/bin/bash

APP_NAME="Obsidian"
APP_DESCRIPTION="Markdown-based note taking"
APP_DEFAULT=1
APP_BIN=obsidian

app_installed() {
  dpkg_installed obsidian || has_command obsidian
}

app_install() {
  cd /tmp
  OBSIDIAN_VERSION=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
  wget -O obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/latest/download/obsidian_${OBSIDIAN_VERSION}_amd64.deb"
  sudo apt-get install -y ./obsidian.deb
  rm obsidian.deb
  cd -
}

app_uninstall() {
  apt_remove "$APP_NAME" obsidian
}
