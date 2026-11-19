#!/bin/bash

APP_NAME="OpenCode desktop"
APP_DESCRIPTION="OpenCode as a desktop application"
APP_DEFAULT=1
APP_BIN=OpenCode

app_installed() {
  dpkg_installed opencode || dpkg_installed open-code || dpkg_installed opencode-desktop ||
    has_command OpenCode ||
    desktop_file_exists OpenCode.desktop || desktop_file_exists '@opencode-aidesktop.desktop'
}

app_install() {
  cd /tmp
  wget https://opencode.ai/download/stable/linux-x64-deb -O opencode.deb
  sudo apt-get install -y ./opencode.deb
  rm opencode.deb
  cd -
}

app_uninstall() {
  apt_remove "$APP_NAME" opencode open-code opencode-desktop
  sudo rm -f /usr/bin/OpenCode
  echo "Kept OpenCode user data in ~/.local/share and ~/.config."
}
