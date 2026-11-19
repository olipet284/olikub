#!/bin/bash

APP_NAME="Pinta"
APP_DESCRIPTION="Simple drawing and image editing"
APP_DEFAULT=1

app_installed() {
  flatpak_installed com.github.PintaProject.Pinta
}

app_install() {
  flatpak install -y flathub com.github.PintaProject.Pinta
}

app_uninstall() {
  flatpak uninstall -y flathub com.github.PintaProject.Pinta
}
