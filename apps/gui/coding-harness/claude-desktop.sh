#!/bin/bash

APP_NAME="Claude Desktop"
APP_DESCRIPTION="Claude Code in a desktop app"
APP_DEFAULT=0
APP_BIN=claude-desktop

app_installed() {
  dpkg_installed claude-desktop || has_command claude-desktop ||
    desktop_file_exists claude-desktop.desktop
}

app_install() {
  sudo curl -fsSLo /usr/share/keyrings/claude-desktop-archive-keyring.asc \
    https://downloads.claude.ai/claude-desktop/key.asc
  echo "deb [signed-by=/usr/share/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main" |
    sudo tee /etc/apt/sources.list.d/claude-desktop.list >/dev/null

  sudo apt-get update
  sudo apt-get install -y claude-desktop
}

app_uninstall() {
  apt_remove "$APP_NAME" claude-desktop
  sudo rm -f /etc/apt/sources.list.d/claude-desktop.list \
    /usr/share/keyrings/claude-desktop-archive-keyring.asc
  echo "Kept Claude user data in ~/.config and ~/.local/share."
}
