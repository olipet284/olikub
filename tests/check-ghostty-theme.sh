#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/empty"

cat > "$tmp/bin/ghostty" <<'MOCK'
#!/bin/bash
exit 0
MOCK
chmod +x "$tmp/bin/ghostty"

run() {
  HOME="$1" OLIKUB_GHOSTTY_THEME="$2" PATH="$3" \
    /bin/bash -c 'source "$1/themes/set-ghostty-theme.sh"' _ "$root"
}

theme_file="$tmp/fresh/.config/ghostty/olikub-theme-override.ghostty"

# Ghostty absent: nothing is written.
mkdir -p "$tmp/noghostty"
run "$tmp/noghostty" TokyoNight "$tmp/empty"
[[ ! -e "$tmp/noghostty/.config/ghostty/olikub-theme-override.ghostty" ]]

# Fresh setup writes the theme to olikub's own override file.
mkdir -p "$tmp/fresh"
run "$tmp/fresh" TokyoNight "$tmp/bin:/usr/bin:/bin"
grep -Fx 'theme = TokyoNight' "$theme_file" >/dev/null

# The user's own ghostty config is never touched.
mkdir -p "$tmp/untouched/.config/ghostty"
printf '%s\n' \
  'window-decoration = false' \
  'theme = Catppuccin Macchiato' \
  'confirm-close-surface = false' \
  > "$tmp/untouched/.config/ghostty/config"
run "$tmp/untouched" 'Everforest Dark Hard' "$tmp/bin:/usr/bin:/bin"
grep -Fx 'window-decoration = false' "$tmp/untouched/.config/ghostty/config" >/dev/null
grep -Fx 'theme = Catppuccin Macchiato' "$tmp/untouched/.config/ghostty/config" >/dev/null

# A stale override file is replaced rather than appended to.
mkdir -p "$tmp/stale/.config/ghostty"
printf '%s\n' 'theme = Catppuccin Macchiato' > "$tmp/stale/.config/ghostty/olikub-theme-override.ghostty"
run "$tmp/stale" Nord "$tmp/bin:/usr/bin:/bin"
grep -Fx 'theme = Nord' "$tmp/stale/.config/ghostty/olikub-theme-override.ghostty" >/dev/null
[[ "$(wc -l < "$tmp/stale/.config/ghostty/olikub-theme-override.ghostty")" -eq 1 ]]

echo 'Ghostty theme checks passed.'
