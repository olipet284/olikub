#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin/olikub-sub" "$tmp/bin-path"
cp "$root/bin/olikub" "$tmp/bin/olikub"
cp "$root/bin/olikub-sub/menu.sh" "$tmp/bin/olikub-sub/menu.sh"
: > "$tmp/bin/olikub-sub/header.sh"
cat > "$tmp/bin/olikub-sub/theme.sh" <<'THEME'
printf '%s\n' "theme args: $#" >> "$THEME_LOG"
source "$OLIKUB_PATH/bin/olikub-sub/menu.sh"
THEME
cat > "$tmp/bin-path/gum" <<'GUM'
#!/usr/bin/env bash
printf '%s\n' Quit
GUM
chmod +x "$tmp/bin-path/gum"

OLIKUB_PATH="$tmp" THEME_LOG="$tmp/theme.log" PATH="$tmp/bin-path:/usr/bin:/bin" \
  bash "$tmp/bin/olikub" theme
grep -Fx 'theme args: 0' "$tmp/theme.log" >/dev/null

echo 'Olikub theme command checks passed.'
