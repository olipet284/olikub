#!/bin/bash

set -e

is_official_origin() {
  local origin=${1%.git}
  [[ $origin == https://github.com/olipet284/olikub ||
    $origin == git@github.com:olipet284/olikub ||
    $origin == ssh://git@github.com/olipet284/olikub ]]
}
cd "$OLIKUB_PATH"
[[ $(git rev-parse --show-toplevel) == "$(pwd -P)" ]] || { echo 'Olikub path is not a Git worktree root.' >&2; exit 1; }
[[ $(git symbolic-ref --quiet --short HEAD || true) == main ]] || { echo 'Olikub updates run from the main branch only.' >&2; exit 1; }
is_official_origin "$(git config --get remote.origin.url || true)" || { echo 'Olikub origin does not match the official public repository.' >&2; exit 1; }
[[ -z $(git status --porcelain) ]] || { echo 'Olikub checkout has local changes; commit, stash, or discard them before updating.' >&2; exit 1; }
git pull --ff-only origin main

cd -
