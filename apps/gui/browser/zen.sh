#!/bin/bash

APP_NAME="Zen"
APP_DESCRIPTION="Privacy-focused Firefox-based browser"
APP_DEFAULT=0
APP_BIN=zen

ZEN_FLATPAK_ID=app.zen_browser.zen

app_installed() {
  flatpak_installed "$ZEN_FLATPAK_ID" || has_command zen
}

app_install() {
  flatpak install -y flathub "$ZEN_FLATPAK_ID"
}

app_uninstall() {
  flatpak uninstall -y "$ZEN_FLATPAK_ID"
}
