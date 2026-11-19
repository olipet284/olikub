#!/bin/bash

APP_NAME="Termusic"
APP_DESCRIPTION="Terminal music player"
APP_DEFAULT=1
APP_BIN=termusic

app_installed() {
  has_command termusic
}

app_install() {
  # Install dependencies
  sudo apt-get install -y protobuf-compiler libdbus-1-dev libasound2-dev libopus0 libopus-dev

  cargo install termusic termusic-server --locked
}

app_uninstall() {
  if has_command cargo; then
    cargo uninstall termusic || true
    cargo uninstall termusic-server || true
  else
    echo "$APP_NAME is installed but Cargo is unavailable; leaving it in place."
  fi
}
