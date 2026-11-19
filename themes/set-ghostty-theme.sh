#!/bin/bash

if ! command -v ghostty &>/dev/null; then
  return 0
fi

# The user's ghostty config (`config`, `config.ghostty`, ...) stays untouched.
# Olikub owns only this file, which the user's config pulls in with:
#   config-file = ?olikub-theme-override.ghostty
GHOSTTY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
GHOSTTY_THEME_CONFIG="$GHOSTTY_CONFIG_DIR/olikub-theme-override.ghostty"

mkdir -p "$GHOSTTY_CONFIG_DIR"
printf 'theme = %s\n' "$OLIKUB_GHOSTTY_THEME" > "$GHOSTTY_THEME_CONFIG"
