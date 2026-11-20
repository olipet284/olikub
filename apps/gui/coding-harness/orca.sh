#!/bin/bash

APP_NAME="Orca"
APP_DESCRIPTION="Desktop environment for running coding agents"
APP_DEFAULT=0
APP_BIN=orca-ide

app_installed() {
  dpkg_installed orca-ide || has_command orca-ide
}

app_install() {
  local url
  url="$(curl -fsSL https://api.github.com/repos/stablyai/orca/releases/latest |
    grep -o 'https://[^"]*_amd64\.deb' | head -1)"
  if [[ -z "$url" ]]; then
    echo "Could not find an Orca .deb for amd64." >&2
    return 1
  fi

  (
    cd /tmp || return 1
    curl -fsSL -o orca.deb "$url"
    sudo apt-get install -y ./orca.deb
    rm -f /tmp/orca.deb
  )
}

app_uninstall() {
  apt_remove "$APP_NAME" orca-ide
  echo "Kept Orca worktree data in ~/.config and ~/.local/share."
}
