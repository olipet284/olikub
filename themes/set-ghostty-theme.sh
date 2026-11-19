#!/bin/bash

if ! command -v ghostty &>/dev/null; then
  return 0
fi

# Ghostty reads both `config` and `config.ghostty`. Olikub owns `config` and
# only writes the theme there, leaving the user's `config.ghostty` (window
# decoration, fonts, ...) untouched.
GHOSTTY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
GHOSTTY_CONFIG="$GHOSTTY_CONFIG_DIR/config"

mkdir -p "$GHOSTTY_CONFIG_DIR"

if grep -q '^[[:space:]]*theme[[:space:]]*=' "$GHOSTTY_CONFIG" 2>/dev/null; then
  sed -i "s|^[[:space:]]*theme[[:space:]]*=.*|theme = $OLIKUB_GHOSTTY_THEME|" "$GHOSTTY_CONFIG"
else
  printf 'theme = %s\n' "$OLIKUB_GHOSTTY_THEME" >> "$GHOSTTY_CONFIG"
fi
