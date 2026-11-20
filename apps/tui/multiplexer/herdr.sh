#!/bin/bash

APP_NAME="Herdr"
APP_DESCRIPTION="Agent-aware terminal multiplexer"
APP_DEFAULT=0
APP_BIN=herdr

app_installed() {
  has_command herdr || mise_manages_command herdr
}

app_install() {
  mise use -g herdr
}

app_uninstall() {
  mise unuse -g herdr 2>/dev/null || true
}
