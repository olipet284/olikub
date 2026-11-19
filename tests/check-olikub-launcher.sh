#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/home/.local/share/applications"
HOME="$tmp/home" OLIKUB_PATH="$root" bash "$root/launchers/Olikub.sh"

launcher="$tmp/home/.local/share/applications/Olikub.desktop"
grep -F -- '-e bash -ic olikub' "$launcher" >/dev/null
grep -F -- "--config-file \"$tmp/home/.config/alacritty/pane.toml\"" "$launcher" >/dev/null
grep -Fx 'Categories=Utility;' "$launcher" >/dev/null
if command -v desktop-file-validate >/dev/null; then
  desktop-file-validate "$launcher"
fi

echo 'Olikub launcher checks passed.'
