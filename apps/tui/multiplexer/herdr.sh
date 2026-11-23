#!/bin/bash

APP_NAME="Herdr"
APP_DESCRIPTION="Agent-aware terminal multiplexer"
APP_DEFAULT=0
APP_BIN=herdr

app_installed() {
  [[ -x "$HOME/.local/bin/herdr" ]] || has_command herdr
}

app_install() {
  curl -fsSL https://herdr.dev/install.sh | sh
}

app_uninstall() {
  remove_user_binary "$APP_NAME" "$HOME/.local/bin/herdr"
}
