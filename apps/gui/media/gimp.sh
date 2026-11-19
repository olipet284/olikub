#!/bin/bash

APP_NAME="GIMP"
APP_DESCRIPTION="Image manipulation tool"
APP_DEFAULT=0
APP_BIN=gimp

app_installed() {
  flatpak_installed org.gimp.GIMP || has_command gimp
}

app_install() {
  flatpak install -y flathub org.gimp.GIMP
}

app_uninstall() {
  if flatpak_installed org.gimp.GIMP; then
    flatpak uninstall -y flathub org.gimp.GIMP
  else
    echo "$APP_NAME is installed outside the supported Flatpak; leaving it in place."
  fi
}
