#!/bin/bash

APP_NAME="Pi"
APP_DESCRIPTION="Minimal, extensible terminal coding agent"
APP_DEFAULT=0
APP_BIN=pi

app_installed() {
  has_command pi || mise_manages_command pi
}

app_install() {
  mise use -g pi
}

app_uninstall() {
  mise unuse -g pi 2>/dev/null || true
}
