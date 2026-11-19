#!/bin/bash

APP_NAME="Typora"
APP_DESCRIPTION="Markdown editor and reader"
APP_DEFAULT=0
APP_BIN=typora

app_installed() {
  dpkg_installed typora || has_command typora
}

app_install() {
  if [ ! -f /etc/apt/sources.list.d/typora.list ]; then
    [ -f /etc/apt/keyrings/typora.gpg ] && sudo rm /etc/apt/keyrings/typora.gpg
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://downloads.typora.io/typora.gpg | sudo tee /etc/apt/keyrings/typora.gpg >/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/typora.gpg] https://downloads.typora.io/linux ./" | sudo tee /etc/apt/sources.list.d/typora.list
  fi

  sudo apt-get update
  sudo apt-get install -y typora

  mkdir -p ~/.config/Typora/themes
  cp "$OLIKUB_PATH/configs/typora/ia_typora.css" ~/.config/Typora/themes/
  cp "$OLIKUB_PATH/configs/typora/ia_typora_night.css" ~/.config/Typora/themes/
}

app_uninstall() {
  apt_remove "$APP_NAME" typora
  sudo rm -f /etc/apt/sources.list.d/typora.list /etc/apt/keyrings/typora.gpg
  echo "Kept Typora configuration in ~/.config/Typora."
}
