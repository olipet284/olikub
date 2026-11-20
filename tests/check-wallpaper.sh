#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT

olikub="$tmp/olikub"
home="$tmp/home"
state="$tmp/state"
data="$tmp/data"
log="$tmp/gsettings.log"
mkdir -p "$olikub/bin/olikub-sub" "$olikub/themes/assets" "$home" "$tmp/bin"

cp "$root/bin/olikub-sub/wallpaper.sh" "$olikub/bin/olikub-sub/wallpaper.sh"
cp "$root/themes/assets/ubuntu-wallpaper.svg.template" "$olikub/themes/assets/"
cp -R "$root/themes/tokyo-night" "$olikub/themes/tokyo-night"
cp -R "$root/themes/nord" "$olikub/themes/nord"

# Extra wallpapers sorted by name; non-images must be ignored.
printf 'a' >"$olikub/themes/tokyo-night/wallpapers/aa.jpg"
printf 'b' >"$olikub/themes/tokyo-night/wallpapers/bb spaced.png"
printf 'c' >"$olikub/themes/tokyo-night/wallpapers/cc.webp"
printf 'ignore' >"$olikub/themes/tokyo-night/wallpapers/notes.txt"

cat >"$tmp/bin/gsettings" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$GSETTINGS_LOG"
MOCK
chmod +x "$tmp/bin/gsettings"

run() {
  HOME="$home" XDG_STATE_HOME="$state" XDG_DATA_HOME="$data" \
    GSETTINGS_LOG="$log" OLIKUB_PATH="$olikub" \
    PATH="$tmp/bin:/usr/bin:/bin" \
    bash "$olikub/bin/olikub-sub/wallpaper.sh" "$@"
}

applied() {
  sed -n 's|^set org.gnome.desktop.background picture-uri ||p' "$log" | tail -1
}

run generate tokyo-night >/dev/null
[[ -f "$data/backgrounds/olikub-tokyo-night-ubuntu.svg" ]]
grep -F "fill=\"#1a1b26\"" "$data/backgrounds/olikub-tokyo-night-ubuntu.svg" >/dev/null
grep -F "fill=\"#bb9af7\"" "$data/backgrounds/olikub-tokyo-night-ubuntu.svg" >/dev/null

# Applying a theme starts on the logo wallpaper and records both URIs.
run apply tokyo-night >/dev/null
[[ "$(applied)" == "$data/backgrounds/olikub-tokyo-night-ubuntu.svg" ]]
[[ $(grep -c '^set org.gnome.desktop.background picture-uri-dark ' "$log") -eq 1 ]]
[[ $(cat "$state/olikub/theme") == "tokyo-night" ]]
[[ $(cat "$state/olikub/wallpaper-index") == "0" ]]

# next walks the directory alphabetically and wraps back to the logo.
run next >/dev/null
[[ "$(applied)" == "$data/backgrounds/olikub-tokyo-night-aa.jpg" ]]
[[ $(cat "$state/olikub/wallpaper-index") == "1" ]]

run next >/dev/null
[[ "$(applied)" == "$data/backgrounds/olikub-tokyo-night-background.jpg" ]]

run next >/dev/null
[[ "$(applied)" == "$data/backgrounds/olikub-tokyo-night-bb spaced.png" ]]

run next >/dev/null
[[ "$(applied)" == "$data/backgrounds/olikub-tokyo-night-cc.webp" ]]

run next >/dev/null
[[ "$(applied)" == "$data/backgrounds/olikub-tokyo-night-ubuntu.svg" ]]
[[ $(cat "$state/olikub/wallpaper-index") == "0" ]]

# prev wraps backwards from the logo.
run prev >/dev/null
[[ "$(applied)" == "$data/backgrounds/olikub-tokyo-night-cc.webp" ]]

# Switching themes resets to that theme's logo and uses its own colors.
run apply nord >/dev/null
[[ "$(applied)" == "$data/backgrounds/olikub-nord-ubuntu.svg" ]]
[[ $(cat "$state/olikub/theme") == "nord" ]]
[[ $(cat "$state/olikub/wallpaper-index") == "0" ]]
grep -F "fill=\"#2e3440\"" "$data/backgrounds/olikub-nord-ubuntu.svg" >/dev/null
grep -F "fill=\"#88c0d0\"" "$data/backgrounds/olikub-nord-ubuntu.svg" >/dev/null
run next >/dev/null
[[ "$(applied)" == "$data/backgrounds/olikub-nord-background.png" ]]

# Generating all themes writes one wallpaper each.
[[ $(run generate all | wc -l) -eq 2 ]]

echo 'Wallpaper checks passed.'