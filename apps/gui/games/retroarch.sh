#!/bin/bash

APP_NAME="RetroArch"
APP_DESCRIPTION="Retro game emulator frontend"
APP_DEFAULT=0

app_installed() {
  flatpak_installed org.libretro.RetroArch
}

app_install() {
  flatpak install -y flathub org.libretro.RetroArch
}

app_uninstall() {
  flatpak uninstall -y flathub org.libretro.RetroArch
}
