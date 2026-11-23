#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/empty" "$tmp/log"

cat > "$tmp/bin/herdr" <<'MOCK'
#!/bin/bash
printf '%s\n' "$*" >> "${HERDR_LOG:?}"
MOCK
chmod +x "$tmp/bin/herdr"

run() {
  HOME="$1" OLIKUB_HERDR_THEME="$2" PATH="$3" HERDR_LOG="$4" \
    /bin/bash -c 'source "$1/themes/set-herdr-theme.sh"' _ "$root"
}

config() {
  printf '%s/config.toml' "$1/.config/herdr"
}

# Herdr absent: nothing is written.
mkdir -p "$tmp/noherdr"
run "$tmp/noherdr" tokyo-night "$tmp/empty" "$tmp/log/absent"
[[ ! -e "$tmp/noherdr/.config/herdr" ]]

# A fresh setup writes only the marker and the theme block.
mkdir -p "$tmp/fresh"
run "$tmp/fresh" tokyo-night "$tmp/bin:/usr/bin:/bin" "$tmp/log/fresh"
grep -Fx '[theme]' "$(config "$tmp/fresh")" >/dev/null
grep -Fx 'name = "tokyo-night"' "$(config "$tmp/fresh")" >/dev/null
[[ "$(grep -c 'olikub theme' "$(config "$tmp/fresh")")" -eq 1 ]]
[[ "$(wc -l < "$(config "$tmp/fresh")")" -eq 3 ]]
grep -Fx 'server reload-config' "$tmp/log/fresh" >/dev/null

# Everything above a stale theme block survives, and the block is replaced.
mkdir -p "$tmp/stale/.config/herdr"
cat > "$(config "$tmp/stale")" <<'TOML'
onboarding = false

[keys]
split_vertical = ["prefix+v", "prefix+%"]

# --- olikub theme (rewritten by `olikub theme`) ---
[theme]
name = "nord"
TOML
run "$tmp/stale" gruvbox "$tmp/bin:/usr/bin:/bin" "$tmp/log/stale"
grep -Fx 'onboarding = false' "$(config "$tmp/stale")" >/dev/null
grep -Fx 'split_vertical = ["prefix+v", "prefix+%"]' "$(config "$tmp/stale")" >/dev/null
grep -Fx 'name = "gruvbox"' "$(config "$tmp/stale")" >/dev/null
! grep -Fx 'name = "nord"' "$(config "$tmp/stale")" >/dev/null
[[ "$(grep -c '^\[theme\]' "$(config "$tmp/stale")")" -eq 1 ]]
[[ "$(grep -c 'olikub theme' "$(config "$tmp/stale")")" -eq 1 ]]

# A config symlinked out of a dotfiles repository stays linked.
mkdir -p "$tmp/link/.config/herdr" "$tmp/dotfiles/config/herdr"
cat > "$tmp/dotfiles/config/herdr/config.toml" <<'TOML'
[keys]
next_tab = "ctrl+tab"
TOML
ln -s "$tmp/dotfiles/config/herdr/config.toml" "$(config "$tmp/link")"
run "$tmp/link" catppuccin "$tmp/bin:/usr/bin:/bin" "$tmp/log/link"
[[ -L "$(config "$tmp/link")" ]]
[[ "$(readlink "$(config "$tmp/link")")" == "$tmp/dotfiles/config/herdr/config.toml" ]]
grep -Fx 'next_tab = "ctrl+tab"' "$tmp/dotfiles/config/herdr/config.toml" >/dev/null
grep -Fx 'name = "catppuccin"' "$tmp/dotfiles/config/herdr/config.toml" >/dev/null

# A dangling symlink cannot be written through, so it is replaced.
mkdir -p "$tmp/dangling/.config/herdr"
ln -s "$tmp/gone/config.toml" "$(config "$tmp/dangling")"
run "$tmp/dangling" nord "$tmp/bin:/usr/bin:/bin" "$tmp/log/dangling"
[[ ! -L "$(config "$tmp/dangling")" ]]
grep -Fx 'name = "nord"' "$(config "$tmp/dangling")" >/dev/null

# Every theme ships a hook that names one of herdr's built-in themes.
builtin_themes='catppuccin catppuccin-latte terminal tokyo-night tokyo-night-day dracula nord gruvbox
gruvbox-light one-dark one-light solarized solarized-light kanagawa kanagawa-lotus rose-pine
rose-pine-dawn vesper'
themes=0
for directory in "$root"/themes/*/; do
  [[ -f "$directory/theme.conf" ]] || continue
  theme=$(basename "$directory")
  hook="$directory/herdr.sh"
  [[ -f "$hook" ]] || {
    printf 'missing %s\n' "$hook" >&2
    exit 1
  }
  name=$(sed -n 's/^OLIKUB_HERDR_THEME="\(.*\)"$/\1/p' "$hook")
  [[ -n "$name" ]] || {
    printf 'no OLIKUB_HERDR_THEME in %s\n' "$hook" >&2
    exit 1
  }
  case " ${builtin_themes//$'\n'/ } " in
    *" $name "*) ;;
    *)
      printf 'theme %s names an unknown herdr theme: %s\n' "$theme" "$name" >&2
      exit 1
      ;;
  esac
  themes=$((themes + 1))
done
[[ "$themes" -eq 10 ]]

echo 'Herdr theme checks passed.'
