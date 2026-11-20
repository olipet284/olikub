#!/bin/bash

APP_NAME="GitHub Copilot CLI"
APP_DESCRIPTION="GitHub Copilot in the terminal"
APP_DEFAULT=0
APP_BIN=copilot

app_installed() {
  has_command copilot || mise_manages_command copilot
}

app_install() {
  mise use -g copilot
}

app_uninstall() {
  mise unuse -g copilot 2>/dev/null || true
}
