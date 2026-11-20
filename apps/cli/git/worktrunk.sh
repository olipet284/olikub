#!/bin/bash

APP_NAME="Worktrunk"
APP_DESCRIPTION="Git worktree management for parallel agents"
APP_DEFAULT=0
APP_BIN=wt

app_installed() {
  has_command wt || mise_manages_command wt
}

app_install() {
  if ! has_command cargo; then
    echo "Worktrunk needs Rust/Cargo. Select Rust in the dev language recipe first." >&2
    return 1
  fi
  mise use -g cargo:worktrunk
}

app_uninstall() {
  mise unuse -g cargo:worktrunk 2>/dev/null || true
}
