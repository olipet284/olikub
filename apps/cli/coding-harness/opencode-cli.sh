#!/bin/bash

APP_NAME="OpenCode CLI"
APP_DESCRIPTION="Terminal coding agent"
APP_DEFAULT=1
APP_BIN=opencode

app_installed() {
  has_command opencode || mise_manages_command opencode
}

app_install() {
  mise use -g opencode
}

app_uninstall() {
  mise unuse -g opencode 2>/dev/null || true
}
