#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin"

cat > "$tmp/bin/gsettings" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$GSETTINGS_LOG"
MOCK
chmod +x "$tmp/bin/gsettings"

GSETTINGS_LOG="$tmp/gsettings.log" PATH="$tmp/bin:/usr/bin:/bin" \
  bash "$root/install/desktop/set-dock.sh"
grep -Fx 'set org.gnome.shell favorite-apps []' "$tmp/gsettings.log" >/dev/null

echo 'Dock checks passed.'
