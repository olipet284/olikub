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

# Ghostty absent: nothing is written.
mkdir -p "$tmp/noghostty"
run "$tmp/noghostty" TokyoNight "$tmp/empty"
[[ ! -e "$tmp/noghostty/.config/ghostty/config" ]]

# Fresh config gets the theme.
mkdir -p "$tmp/fresh"
run "$tmp/fresh" TokyoNight "$tmp/bin:/usr/bin:/bin"
grep -Fx 'theme = TokyoNight' "$tmp/fresh/.config/ghostty/config" >/dev/null

# An existing theme line is replaced; other settings are preserved.
mkdir -p "$tmp/existing/.config/ghostty"
printf '%s\n' \
  'window-decoration = false' \
  'theme = Catppuccin Macchiato' \
  'confirm-close-surface = false' \
  > "$tmp/existing/.config/ghostty/config"
run "$tmp/existing" 'Everforest Dark Hard' "$tmp/bin:/usr/bin:/bin"
grep -Fx 'theme = Everforest Dark Hard' "$tmp/existing/.config/ghostty/config" >/dev/null
grep -Fx 'window-decoration = false' "$tmp/existing/.config/ghostty/config" >/dev/null
grep -Fx 'confirm-close-surface = false' "$tmp/existing/.config/ghostty/config" >/dev/null

# A config without a theme line gets one appended.
mkdir -p "$tmp/append/.config/ghostty"
printf '%s\n' 'window-decoration = false' > "$tmp/append/.config/ghostty/config"
run "$tmp/append" Nord "$tmp/bin:/usr/bin:/bin"
grep -Fx 'theme = Nord' "$tmp/append/.config/ghostty/config" >/dev/null
grep -Fx 'window-decoration = false' "$tmp/append/.config/ghostty/config" >/dev/null

echo 'Ghostty theme checks passed.'
