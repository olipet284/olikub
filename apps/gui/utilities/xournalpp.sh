#!/bin/bash

APP_NAME="Xournal++"
APP_DESCRIPTION="Handwritten notes and PDF annotation"
APP_DEFAULT=1
APP_BIN=xournalpp

app_installed() {
  has_command xournalpp || dpkg_installed xournalpp
}

app_install() {
  sudo apt-get install -y xournalpp
}

app_uninstall() {
  apt_remove "$APP_NAME" xournalpp
}
