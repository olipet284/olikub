#!/bin/bash

APP_NAME="Snowflake CoCo CLI"
APP_DESCRIPTION="Snowflake's AI coding agent"
APP_DEFAULT=0
APP_BIN=cortex

app_installed() {
  has_command cortex
}

app_install() {
  curl -LsS https://ai.snowflake.com/static/cc-scripts/install.sh | sh
}

app_uninstall() {
  remove_user_binary "$APP_NAME" "$HOME/.local/bin/cortex"
}
