#!/bin/bash

APP_NAME="Helium"
APP_DESCRIPTION="Private, fast browser"
APP_DEFAULT=0
APP_BIN=helium

app_installed() {
  dpkg_installed helium-bin || has_command helium
}

app_install() {
  if [ ! -f /usr/share/keyrings/helium.gpg ]; then
    curl -fsSL https://raw.githubusercontent.com/imputnet/helium-linux/main/pubkey.asc |
      sudo gpg --dearmor -o /usr/share/keyrings/helium.gpg
  fi
  echo "deb [signed-by=/usr/share/keyrings/helium.gpg] https://pkg.helium.computer/deb stable main" |
    sudo tee /etc/apt/sources.list.d/helium.list >/dev/null

  sudo apt-get update
  sudo apt-get install -y helium-bin
}

app_uninstall() {
  apt_remove "$APP_NAME" helium-bin
  sudo rm -f /etc/apt/sources.list.d/helium.list /usr/share/keyrings/helium.gpg
}
