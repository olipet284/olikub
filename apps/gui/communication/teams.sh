#!/bin/bash

APP_NAME="Teams"
APP_DESCRIPTION="Microsoft Teams desktop client"
APP_DEFAULT=0
APP_BIN=teams-for-linux

TEAMS_FLATPAK_ID=com.github.IsmaelMartinez.teams_for_linux

app_installed() {
  flatpak_installed "$TEAMS_FLATPAK_ID" || has_command teams-for-linux
}

app_install() {
  flatpak install -y flathub "$TEAMS_FLATPAK_ID"
}

app_uninstall() {
  flatpak uninstall -y "$TEAMS_FLATPAK_ID"
}
