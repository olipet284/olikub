#!/bin/bash

APP_NAME="Codex"
APP_DESCRIPTION="OpenAI's terminal coding agent"
APP_DEFAULT=0
APP_BIN=codex

app_installed() {
  has_command codex || mise_manages_command codex
}

app_install() {
  mise use -g codex
}

app_uninstall() {
  mise unuse -g codex 2>/dev/null || true
}
