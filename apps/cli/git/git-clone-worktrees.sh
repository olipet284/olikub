#!/bin/bash

APP_NAME="git-clone-worktrees"
APP_DESCRIPTION="Clone a repo as a bare repo plus a worktree"
APP_DEFAULT=0
APP_BIN=git-clone-worktrees

GIT_CLONE_WORKTREES_REPO="https://github.com/olipet284/git-clone-worktrees"

app_installed() {
  [[ -x "$HOME/.local/bin/git-clone-worktrees" ]]
}

app_install() {
  local dir
  dir="$(olikub_app_clone git-clone-worktrees "$GIT_CLONE_WORKTREES_REPO")" || return 1
  bash "$dir/setup.sh"
}

app_uninstall() {
  remove_user_binary "$APP_NAME" "$HOME/.local/bin/git-clone-worktrees"
  echo "Kept checkout in $(olikub_apps_data_dir)/git-clone-worktrees."
}
