#!/bin/bash

APP_NAME="Minecraft"
APP_DESCRIPTION="Blocky building game"
APP_DEFAULT=0

app_installed() {
  dpkg_installed minecraft-launcher
}

app_install() {
  sudo apt-get install -y openjdk-8-jdk

  cd /tmp
  wget https://launcher.mojang.com/download/Minecraft.deb
  sudo apt-get install -y ./Minecraft.deb
  rm Minecraft.deb
  cd -
}

app_uninstall() {
  apt_remove "$APP_NAME" minecraft-launcher
}
