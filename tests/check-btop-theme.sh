#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin"

cat > "$tmp/bin/sudo" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
cat > "$tmp/bin/gum" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' 'Tokyo Night'
MOCK
chmod +x "$tmp/bin/sudo" "$tmp/bin/gum"

run_btop_install() {
  HOME="$1" OLIKUB_PATH="$root" PATH="$tmp/bin:/usr/bin:/bin" \
    bash -c 'source "$OLIKUB_PATH/lib/apps.sh"; app_run "$OLIKUB_PATH/apps/tui/system/btop.sh" install'
}

# A first install seeds the stable theme name and leaves a stale old theme link alone.
mkdir -p "$tmp/fresh-home/.config/btop/themes"
ln -s "$tmp/missing-theme" "$tmp/fresh-home/.config/btop/themes/tokyo-night.theme"
run_btop_install "$tmp/fresh-home"
grep -Fx 'color_theme = "olikub"' "$tmp/fresh-home/.config/btop/btop.conf" >/dev/null
cmp "$root/themes/tokyo-night/btop.theme" "$tmp/fresh-home/.config/btop/themes/olikub.theme"
[[ -L "$tmp/fresh-home/.config/btop/themes/tokyo-night.theme" ]]

# Migrate an existing regular Olikub config once, preserving its other settings.
mkdir -p "$tmp/old-home/.config/btop/themes"
printf '%s\n' 'color_theme = "catppuccin"' 'user_setting = "keep me"' \
  > "$tmp/old-home/.config/btop/btop.conf"
run_btop_install "$tmp/old-home"
grep -Fx 'color_theme = "olikub"' "$tmp/old-home/.config/btop/btop.conf" >/dev/null
grep -Fx 'user_setting = "keep me"' "$tmp/old-home/.config/btop/btop.conf" >/dev/null

# Updating the selected palette changes only the stable theme file, not btop.conf.
fixture="$tmp/fixture"
mkdir -p "$fixture/themes/tokyo-night" "$fixture/bin/olikub-sub"
printf '%s\n' 'fixture theme' > "$fixture/themes/tokyo-night/btop.theme"
for asset in alacritty.toml zellij.kdl neovim.lua ghostty.sh gnome.sh tophat.sh vscode.sh; do
  : > "$fixture/themes/tokyo-night/$asset"
done
printf '%s\n' 'fixture zellij theme' > "$fixture/themes/tokyo-night/zellij.kdl"
: > "$fixture/bin/olikub-sub/menu.sh"
mkdir -p "$tmp/theme-home/.config/alacritty" "$tmp/theme-home/.config/zellij/themes" \
  "$tmp/theme-home/.config/nvim/lua/plugins" "$tmp/theme-home/.config/btop/themes"
: > "$tmp/theme-home/.config/zellij/config.kdl"
ln -s "$tmp/missing-zellij-theme" "$tmp/theme-home/.config/zellij/themes/tokyo-night.kdl"
printf '%s\n' 'color_theme = "olikub"' 'user_setting = "preserve"' \
  > "$tmp/theme-home/.config/btop/btop.conf"
cp "$tmp/theme-home/.config/btop/btop.conf" "$tmp/btop.conf.before"
HOME="$tmp/theme-home" OLIKUB_PATH="$fixture" PATH="$tmp/bin:/usr/bin:/bin" \
  bash "$root/bin/olikub-sub/theme.sh"
cmp "$tmp/btop.conf.before" "$tmp/theme-home/.config/btop/btop.conf"
grep -Fx 'fixture theme' "$tmp/theme-home/.config/btop/themes/olikub.theme" >/dev/null
[[ ! -e "$tmp/theme-home/.config/btop/themes/tokyo-night.theme" ]]
grep -Fx 'fixture zellij theme' "$tmp/theme-home/.config/zellij/themes/tokyo-night.kdl" >/dev/null
[[ ! -L "$tmp/theme-home/.config/zellij/themes/tokyo-night.kdl" ]]

# Re-running the installer must not write through a dotfiles-managed config symlink.
mkdir -p "$tmp/linked-home/.config/btop/themes" "$tmp/dotfiles"
printf '%s\n' 'color_theme = "catppuccin"' 'user_setting = "keep me"' > "$tmp/dotfiles/btop.conf"
cp "$tmp/dotfiles/btop.conf" "$tmp/dotfiles/btop.conf.before"
ln -s "$tmp/dotfiles/btop.conf" "$tmp/linked-home/.config/btop/btop.conf"
run_btop_install "$tmp/linked-home"
cmp "$tmp/dotfiles/btop.conf.before" "$tmp/dotfiles/btop.conf"
[[ -L "$tmp/linked-home/.config/btop/btop.conf" ]]

echo 'Btop theme checks passed.'
