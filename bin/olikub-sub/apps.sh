#!/bin/bash

# List catalog apps with their detected status, or install/uninstall a single
# app by id. This is the escape hatch when detection does not match reality:
#
#   olikub apps
#   olikub apps list
#   olikub apps install lazygit
#   olikub apps uninstall lazygit

source "$OLIKUB_PATH/lib/apps.sh"

action="${1:-list}"
(($#)) && shift || true

case "$action" in
  list)
    olikub_apps_status
    ;;
  install|uninstall)
    (($#)) || { echo "usage: olikub apps $action <app-id>" >&2; exit 2; }
    for id in "$@"; do
      if ! file="$(app_find "$id")"; then
        echo "error: unknown app: $id" >&2
        exit 1
      fi
      apps_apply "$action" "$file"
    done
    ;;
  *)
    echo "usage: olikub apps [list|install|uninstall] [app-id...]" >&2
    exit 2
    ;;
esac
