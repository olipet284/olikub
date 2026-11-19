#!/bin/bash

APP_NAME="Zed"
APP_DESCRIPTION="Fast all-purpose code editor"
APP_DEFAULT=1
APP_BIN=zed

app_installed() {
  has_command zed || [[ -x "$HOME/.local/zed.app/bin/zed" ]] || dpkg_installed zed
}

app_install() {
  curl https://zed.dev/install.sh | sh
}

app_uninstall() {
  if dpkg_installed zed; then
    apt_remove "$APP_NAME" zed
  elif [[ -x "$HOME/.local/zed.app/bin/zed" ]]; then
    rm -rf "$HOME/.local/zed.app"
    rm -f "$HOME/.local/bin/zed"
    rm -f "$HOME/.local/share/applications/dev.zed.Zed.desktop"
  else
    echo "$APP_NAME is installed outside the supported Zed install script; leaving it in place."
  fi
}
