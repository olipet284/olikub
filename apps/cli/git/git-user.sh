#!/bin/bash

APP_NAME="git-user"
APP_DESCRIPTION="Switch between GitHub accounts and Git emails"
APP_DEFAULT=0
APP_BIN=git-user

GIT_USER_REPO="https://github.com/olipet284/git-user"

app_installed() {
  [[ -x "$HOME/.local/bin/git-user" ]]
}

app_install() {
  local dir
  dir="$(olikub_app_clone git-user "$GIT_USER_REPO")" || return 1
  bash "$dir/setup.sh"
}

app_uninstall() {
  # Profiles live in the checkout's .env, so keep the checkout and only unlink
  # the command.
  remove_user_binary "$APP_NAME" "$HOME/.local/bin/git-user"
  echo "Kept profiles and checkout in $(olikub_apps_data_dir)/git-user."
}
