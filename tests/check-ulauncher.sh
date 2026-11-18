#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home/.config/autostart" "$tmp/home/.config/ulauncher" "$tmp/dotfiles"

cat > "$tmp/bin/sudo" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
cat > "$tmp/bin/gtk-launch" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' called >> "$GTK_LAUNCH_LOG"
mkdir -p "$HOME/.config/ulauncher"
[[ -e "$HOME/.config/ulauncher/settings.json" || -L "$HOME/.config/ulauncher/settings.json" ]] ||
  printf '%s\n' '{"generated":true}' > "$HOME/.config/ulauncher/settings.json"
MOCK
cat > "$tmp/bin/sleep" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
chmod +x "$tmp/bin/"*

autostart="$tmp/home/.config/autostart/ulauncher.desktop"
settings="$tmp/home/.config/ulauncher/settings.json"
ln -s "$tmp/missing/ulauncher.desktop" "$autostart"
printf '%s\n' '{"user":"keep"}' > "$tmp/dotfiles/ulauncher.json"
ln -s "$tmp/dotfiles/ulauncher.json" "$settings"

HOME="$tmp/home" OLIKUB_PATH="$root" PATH="$tmp/bin:/usr/bin:/bin" \
  GTK_LAUNCH_LOG="$tmp/gtk-launch.log" bash "$root/install/desktop/ulauncher.sh" >/dev/null
[[ -f "$autostart" && ! -L "$autostart" ]]
backup=$(find "$(dirname "$autostart")" -maxdepth 1 -name 'ulauncher.desktop.BAK-*' -print -quit)
[[ -n "$backup" && -L "$backup" ]]
[[ -L "$settings" ]]
grep -F '"user":"keep"' "$tmp/dotfiles/ulauncher.json" >/dev/null
[[ ! -e "$tmp/gtk-launch.log" ]]

fresh_home="$tmp/fresh-home"
HOME="$fresh_home" OLIKUB_PATH="$root" PATH="$tmp/bin:/usr/bin:/bin" \
  GTK_LAUNCH_LOG="$tmp/fresh-gtk-launch.log" bash "$root/install/desktop/ulauncher.sh" >/dev/null
grep -Fx called "$tmp/fresh-gtk-launch.log" >/dev/null
cmp "$root/configs/ulauncher.json" "$fresh_home/.config/ulauncher/settings.json"

echo 'Ulauncher checks passed.'
