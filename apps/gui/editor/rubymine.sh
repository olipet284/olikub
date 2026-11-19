#!/bin/bash

APP_NAME="RubyMine"
APP_DESCRIPTION="JetBrains Ruby and Rails IDE"
APP_DEFAULT=0
APP_BIN=rubymine

app_installed() {
  snap_installed rubymine
}

app_install() {
  sudo snap install rubymine --classic
}

app_uninstall() {
  sudo snap remove rubymine
}
