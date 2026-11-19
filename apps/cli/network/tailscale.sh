#!/bin/bash

APP_NAME="Tailscale"
APP_DESCRIPTION="Mesh VPN based on WireGuard"
APP_DEFAULT=0
APP_BIN=tailscale

app_installed() {
  has_command tailscale || dpkg_installed tailscale
}

app_install() {
  curl -fsSL https://tailscale.com/install.sh | sh
}

app_uninstall() {
  apt_remove "$APP_NAME" tailscale
}
