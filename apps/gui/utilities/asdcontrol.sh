#!/bin/bash

APP_NAME="ASDControl"
APP_DESCRIPTION="Set brightness on Apple Studio and XDR displays"
APP_DEFAULT=0
APP_BIN=asdcontrol

app_installed() {
  has_command asdcontrol
}

app_install() {
  git clone https://github.com/nikosdion/asdcontrol.git /tmp/asdcontrol
  cd /tmp/asdcontrol
  make
  sudo make install
  cd -
  rm -rf /tmp/asdcontrol

  echo 'KERNEL=="hiddev*", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="9243", GROUP="users", OWNER="root", MODE="0660"' | sudo tee /etc/udev/rules.d/50-apple-xdr.rules >/dev/null
  echo 'KERNEL=="hiddev*", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="1114", GROUP="users", OWNER="root", MODE="0660"' | sudo tee /etc/udev/rules.d/50-apple-studio.rules >/dev/null
  sudo udevadm control --reload-rules

  gum confirm "Ready to reboot for brightness controls to be available?" && sudo reboot
}

app_uninstall() {
  remove_local_binary "$APP_NAME" /usr/local/bin/asdcontrol
  sudo rm -f /etc/udev/rules.d/50-apple-xdr.rules /etc/udev/rules.d/50-apple-studio.rules
}
