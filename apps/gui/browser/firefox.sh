#!/bin/bash

APP_NAME="Firefox"
APP_DESCRIPTION="Mozilla web browser"
APP_DEFAULT=0
APP_BIN=firefox

app_installed() {
  has_command firefox || snap_installed firefox
}

app_install() {
  sudo snap install firefox
}

app_uninstall() {
  sudo snap remove firefox
}
