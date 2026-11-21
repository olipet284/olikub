#!/bin/bash

# Obsidian has no system-wide theme file. Olikub installs one theme named
# "Olikub" into every vault and points the vault at it. The active theme's CSS
# is copied to a shared directory once, and each vault's
# .obsidian/themes/Olikub links to that directory, so switching theme rewrites
# a single file.
#
# The per-theme hook sets OLIKUB_OBSIDIAN_CSS and sources this file.

[[ -n ${OLIKUB_OBSIDIAN_CSS:-} ]] || {
  printf 'OLIKUB_OBSIDIAN_CSS is not set\n' >&2
  return 1
}

OBSIDIAN_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian"

# Only act when Obsidian has been used on this machine.
if [[ ! -d $OBSIDIAN_CONFIG_DIR ]] && ! command -v obsidian &>/dev/null; then
  return 0
fi

OBSIDIAN_THEME_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/olikub/obsidian"
OBSIDIAN_THEME_MANIFEST="$OBSIDIAN_THEME_DIR/manifest.json"
OBSIDIAN_THEME_CSS="$OBSIDIAN_THEME_DIR/theme.css"

mkdir -p "$OBSIDIAN_THEME_DIR" || {
  printf 'Cannot create %s\n' "$OBSIDIAN_THEME_DIR" >&2
  return 1
}

cat >"$OBSIDIAN_THEME_MANIFEST" <<'EOF'
{
  "name": "Olikub",
  "version": "1.0.0",
  "minAppVersion": "0.16.0",
  "description": "Automatically follows your current Olikub system theme",
  "author": "Olikub",
  "authorUrl": "https://github.com/olipet284/olikub"
}
EOF

cp "$OLIKUB_OBSIDIAN_CSS" "$OBSIDIAN_THEME_CSS" || {
  printf 'Cannot write %s\n' "$OBSIDIAN_THEME_CSS" >&2
  return 1
}

# Print every vault Olikub should theme: the vaults Obsidian has registered,
# plus any listed in ~/.config/olikub/obsidian-vaults.
olikub_obsidian_vaults() {
  local vault registry="${OBSIDIAN_CONFIG_DIR}/obsidian.json"
  local extra="${XDG_CONFIG_HOME:-$HOME/.config}/olikub/obsidian-vaults"
  declare -A seen=()

  if [[ -f $registry ]]; then
    while IFS= read -r vault; do
      [[ -n $vault && -z ${seen[$vault]:-} ]] || continue
      seen[$vault]=1
      printf '%s\n' "$vault"
    done < <(grep -o '"path"[[:space:]]*:[[:space:]]*"[^"]*"' "$registry" 2>/dev/null |
      sed -e 's/.*"path"[[:space:]]*:[[:space:]]*"//' -e 's/".*//')
  fi

  if [[ -f $extra ]]; then
    while IFS= read -r vault || [[ -n $vault ]]; do
      vault=${vault#"${vault%%[![:space:]]*}"}
      vault=${vault%"${vault##*[![:space:]]}"}
      [[ -n $vault && $vault != \#* ]] || continue
      vault=${vault/#\~/$HOME}
      [[ -z ${seen[$vault]:-} ]] || continue
      seen[$vault]=1
      printf '%s\n' "$vault"
    done <"$extra"
  fi
}

# Point a vault's appearance at the Olikub theme without disturbing its other
# settings. Skipped while Obsidian runs, since it would rewrite the file on
# exit.
olikub_obsidian_select() {
  local appearance="$1/.obsidian/appearance.json"

  if [[ -f $appearance ]]; then
    if grep -q '"cssTheme"' "$appearance"; then
      sed -i 's/"cssTheme"[[:space:]]*:[[:space:]]*"[^"]*"/"cssTheme": "Olikub"/' "$appearance"
    else
      sed -i '0,/{/s//{\n  "cssTheme": "Olikub",/' "$appearance"
    fi
  else
    printf '{\n  "cssTheme": "Olikub"\n}\n' >"$appearance"
  fi
}

# Link the shared theme into a vault. A directory or symlink Olikub did not
# create is left alone.
olikub_obsidian_link() {
  local vault=$1 themes="$1/.obsidian/themes" link="$1/.obsidian/themes/Olikub"

  mkdir -p "$themes" || return 1

  if [[ -L $link ]]; then
    if [[ "$(readlink "$link")" == "$OBSIDIAN_THEME_DIR" ]]; then
      return 0
    fi
    printf 'Leaving existing theme in place: %s\n' "$link" >&2
    return 0
  elif [[ -e $link ]]; then
    printf 'Leaving existing theme in place: %s\n' "$link" >&2
    return 0
  fi

  if ln -s "$OBSIDIAN_THEME_DIR" "$link"; then
    return 0
  fi

  # Filesystems that reject symlinks still get a working copy of the theme.
  mkdir -p "$link" && cp "$OBSIDIAN_THEME_MANIFEST" "$link/manifest.json" &&
    cp "$OBSIDIAN_THEME_CSS" "$link/theme.css"
}

olikub_obsidian_running() {
  command -v pgrep &>/dev/null && pgrep -x obsidian &>/dev/null
}

OBSIDIAN_RUNNING=false
olikub_obsidian_running && OBSIDIAN_RUNNING=true

OBSIDIAN_THEMED=0
while IFS= read -r vault; do
  [[ -d $vault/.obsidian ]] || continue
  olikub_obsidian_link "$vault" || continue
  $OBSIDIAN_RUNNING || olikub_obsidian_select "$vault"
  OBSIDIAN_THEMED=$((OBSIDIAN_THEMED + 1))
done < <(olikub_obsidian_vaults)

if [[ $OBSIDIAN_THEMED -gt 0 && $OBSIDIAN_RUNNING == true ]]; then
  printf 'Obsidian is running; select the "Olikub" theme under Appearance > Themes.\n'
fi

unset -f olikub_obsidian_vaults olikub_obsidian_select olikub_obsidian_link olikub_obsidian_running
