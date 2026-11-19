#!/bin/bash

APP_NAME="Zellij"
APP_DESCRIPTION="Terminal workspace and multiplexer"
APP_DEFAULT=1
APP_BIN=zellij

app_installed() {
  [[ -x /usr/local/bin/zellij ]] || has_command zellij
}

app_install() {
  cd /tmp
  wget -O zellij.tar.gz "https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz"
  tar -xf zellij.tar.gz zellij
  sudo install zellij /usr/local/bin
  rm zellij.tar.gz zellij
  cd -

  mkdir -p ~/.config/zellij/themes
  [ ! -f "$HOME/.config/zellij/config.kdl" ] && cp "$OLIKUB_PATH/configs/zellij.kdl" ~/.config/zellij/config.kdl
  cp "$OLIKUB_PATH/themes/tokyo-night/zellij.kdl" ~/.config/zellij/themes/tokyo-night.kdl
}

app_uninstall() {
  remove_local_binary "$APP_NAME" /usr/local/bin/zellij
}
