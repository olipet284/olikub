#!/bin/bash

APP_NAME="Herdr App"
APP_DESCRIPTION="Run coding agents in a desktop app"
APP_DEFAULT=0
APP_BIN=herdr-app

app_installed() {
  [[ -x "$HOME/.local/bin/herdr-app" ]] || has_command herdr-app
}

app_install() {
  curl -fsSL https://releases.herdr.dev/app/install.sh | sh
}

app_uninstall() {
  local data="${XDG_DATA_HOME:-$HOME/.local/share}"
  rm -rf "$data/herdr-app"
  rm -f "$HOME/.local/bin/herdr-app"
  rm -f "$data/applications/herdr-app.desktop"
  rm -f "$data/icons/hicolor/scalable/apps/herdr-app.svg"
  echo "Kept herdr-core; the Herdr TUI and a reopened app share it."
}
