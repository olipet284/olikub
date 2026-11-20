#!/bin/bash

APP_NAME="Claude Code"
APP_DESCRIPTION="Anthropic's terminal coding agent"
APP_DEFAULT=0
APP_BIN=claude

app_installed() {
  has_command claude || mise_manages_command claude
}

app_install() {
  mise use -g claude
}

app_uninstall() {
  mise unuse -g claude 2>/dev/null || true
}
