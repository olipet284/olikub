#!/bin/bash

APP_NAME="Chromium"
APP_DESCRIPTION="Open-source browser"
APP_DEFAULT=0
APP_BIN=chromium

app_installed() {
  has_command chromium || snap_installed chromium
}

app_install() {
  sudo snap install chromium
}

app_uninstall() {
  sudo snap remove chromium
}
