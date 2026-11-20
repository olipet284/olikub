#!/bin/bash

APP_NAME="Slack"
APP_DESCRIPTION="Team chat and collaboration"
APP_DEFAULT=0
APP_BIN=slack

app_installed() {
  has_command slack || snap_installed slack
}

app_install() {
  sudo snap install slack
}

app_uninstall() {
  sudo snap remove slack
}
