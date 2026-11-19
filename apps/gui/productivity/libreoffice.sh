#!/bin/bash

APP_NAME="LibreOffice"
APP_DESCRIPTION="Office suite for documents, spreadsheets and slides"
APP_DEFAULT=1
APP_BIN=libreoffice

app_installed() {
  has_command libreoffice || dpkg_installed libreoffice
}

app_install() {
  sudo apt-get install -y libreoffice
}

app_uninstall() {
  apt_remove "$APP_NAME" libreoffice libreoffice-core libreoffice-common libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-draw libreoffice-math libreoffice-base
}
