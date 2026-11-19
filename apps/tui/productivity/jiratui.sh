#!/bin/bash

APP_NAME="JiraTUI"
APP_DESCRIPTION="Jira client in the terminal"
APP_DEFAULT=1
APP_BIN=jiratui

app_installed() {
  has_command jiratui
}

app_install() {
  if ! has_command uv; then
    source "$OLIKUB_PATH/install/terminal/required/uv.sh"
    export PATH="$HOME/.local/bin:$PATH"
  fi
  uv tool install jiratui --with "textual[syntax]>=6.4.0,<8.0.0" --force
}

app_uninstall() {
  if has_command uv; then
    uv tool uninstall jiratui || true
  else
    echo "$APP_NAME is installed but uv is unavailable; leaving it in place."
  fi
}
