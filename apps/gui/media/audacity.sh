#!/bin/bash

APP_NAME="Audacity"
APP_DESCRIPTION="Record and edit audio"
APP_DEFAULT=0

app_installed() {
  flatpak_installed org.audacityteam.Audacity
}

app_install() {
  flatpak install -y flathub org.audacityteam.Audacity
}

app_uninstall() {
  flatpak uninstall -y flathub org.audacityteam.Audacity
}
