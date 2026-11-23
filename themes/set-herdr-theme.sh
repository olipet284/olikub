#!/bin/bash

# Herdr keeps its whole configuration in one file and has no config include, so
# Olikub owns the theme block inside `~/.config/herdr/config.toml`: everything
# from the marker line down is rewritten, everything above it (the keybindings
# from a dotfiles repository, say) is left alone. Copying the file over the
# destination keeps a config that is symlinked out of that repository linked.
#
# The per-theme hook sets OLIKUB_HERDR_THEME and sources this file. Herdr only
# accepts its built-in theme names here, so a theme without a matching built-in
# falls back to "terminal", which follows the terminal palette Olikub sets.

if ! command -v herdr >/dev/null 2>&1; then
  return 0
fi

[[ -n ${OLIKUB_HERDR_THEME:-} ]] || {
  printf 'OLIKUB_HERDR_THEME is not set\n' >&2
  return 1
}

HERDR_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/herdr"
HERDR_CONFIG="$HERDR_CONFIG_DIR/config.toml"
HERDR_THEME_MARKER='# --- olikub theme (rewritten by `olikub theme`) ---'

mkdir -p "$HERDR_CONFIG_DIR" || {
  printf 'Cannot create %s\n' "$HERDR_CONFIG_DIR" >&2
  return 1
}

HERDR_THEME_TMP=$(mktemp "${HERDR_CONFIG}.XXXXXX") || {
  printf 'Cannot write %s\n' "$HERDR_CONFIG" >&2
  return 1
}

if [[ -f "$HERDR_CONFIG" ]]; then
  if ! awk -v marker="$HERDR_THEME_MARKER" 'index($0, marker) == 1 { exit } { print }' \
    "$HERDR_CONFIG" >"$HERDR_THEME_TMP"; then
    rm -f -- "$HERDR_THEME_TMP"
    return 1
  fi
fi

printf '%s\n' "$HERDR_THEME_MARKER" >>"$HERDR_THEME_TMP"
printf '[theme]\nname = "%s"\n' "$OLIKUB_HERDR_THEME" >>"$HERDR_THEME_TMP"

# A dangling symlink cannot be written through, so replace it instead.
if [[ -L "$HERDR_CONFIG" && ! -e "$HERDR_CONFIG" ]]; then
  rm -f -- "$HERDR_CONFIG"
fi

if ! cp "$HERDR_THEME_TMP" "$HERDR_CONFIG"; then
  rm -f -- "$HERDR_THEME_TMP"
  return 1
fi
rm -f -- "$HERDR_THEME_TMP"

herdr server reload-config >/dev/null 2>&1 || true
