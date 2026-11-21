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
cat > "$tmp/bin/curl" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
cat > "$tmp/bin/unzip" <<'MOCK'
#!/usr/bin/env bash
exit 0
MOCK
chmod +x "$tmp/bin/sudo" "$tmp/bin/gum" "$tmp/bin/curl" "$tmp/bin/unzip"

# Fixture Olikub checkout with the files theme.sh copies for a theme.
fixture="$tmp/fixture"
mkdir -p "$fixture/themes/tokyo-night" "$fixture/bin/olikub-sub"
printf '%s\n' 'fixture yazi theme' > "$fixture/themes/tokyo-night/yazi-theme.toml"
for asset in alacritty.toml zellij.kdl neovim.lua ghostty.sh gnome.sh tophat.sh vscode.sh; do
  : > "$fixture/themes/tokyo-night/$asset"
done
: > "$fixture/bin/olikub-sub/menu.sh"

prepare_home() {
  local home="$1"
  mkdir -p "$home/.config/alacritty" "$home/.config/zellij/themes"
  : > "$home/.config/zellij/config.kdl"
}

# Switching a theme writes the Yazi theme when Yazi's config directory exists.
home="$tmp/switch"
prepare_home "$home"
mkdir -p "$home/.config/yazi"
HOME="$home" OLIKUB_PATH="$fixture" PATH="$tmp/bin:/usr/bin:/bin" \
  bash "$root/bin/olikub-sub/theme.sh"
grep -Fx 'fixture yazi theme' "$home/.config/yazi/theme.toml" >/dev/null

# Without a Yazi config directory, theme.sh leaves Yazi alone.
home="$tmp/absent"
prepare_home "$home"
HOME="$home" OLIKUB_PATH="$fixture" PATH="$tmp/bin:/usr/bin:/bin" \
  bash "$root/bin/olikub-sub/theme.sh"
[[ ! -e "$home/.config/yazi/theme.toml" ]]

# A dotfiles-managed theme.toml symlink is written through, not replaced.
home="$tmp/linked"
prepare_home "$home"
mkdir -p "$home/.config/yazi" "$tmp/dotfiles"
: > "$tmp/dotfiles/yazi-theme.toml"
ln -s "$tmp/dotfiles/yazi-theme.toml" "$home/.config/yazi/theme.toml"
HOME="$home" OLIKUB_PATH="$fixture" PATH="$tmp/bin:/usr/bin:/bin" \
  bash "$root/bin/olikub-sub/theme.sh"
[[ -L "$home/.config/yazi/theme.toml" ]]
grep -Fx 'fixture yazi theme' "$tmp/dotfiles/yazi-theme.toml" >/dev/null

# Installing Yazi seeds its config and applies the active Olikub theme.
run_install() {
  HOME="$1" XDG_STATE_HOME="$2" OLIKUB_PATH="$root" PATH="$tmp/bin:/usr/bin:/bin" \
    bash -c 'source "$OLIKUB_PATH/lib/apps.sh"; app_run "$OLIKUB_PATH/apps/tui/files/yazi.sh" install'
}

home="$tmp/install-active"
mkdir -p "$tmp/state/olikub"
printf '%s\n' 'nord' > "$tmp/state/olikub/theme"
run_install "$home" "$tmp/state"
cmp "$root/configs/yazi/yazi.toml" "$home/.config/yazi/yazi.toml"
cmp "$root/themes/nord/yazi-theme.toml" "$home/.config/yazi/theme.toml"

# With no recorded theme, install falls back to tokyo-night.
home="$tmp/install-fallback"
mkdir -p "$tmp/empty-state"
run_install "$home" "$tmp/empty-state"
cmp "$root/themes/tokyo-night/yazi-theme.toml" "$home/.config/yazi/theme.toml"

# An existing user config is never overwritten on reinstall.
home="$tmp/install-existing"
mkdir -p "$home/.config/yazi"
printf '%s\n' '# user config' > "$home/.config/yazi/yazi.toml"
printf '%s\n' '# user theme' > "$home/.config/yazi/theme.toml"
cp "$home/.config/yazi/yazi.toml" "$tmp/yazi.toml.before"
run_install "$home" "$tmp/state"
cmp "$tmp/yazi.toml.before" "$home/.config/yazi/yazi.toml"
cmp "$root/themes/nord/yazi-theme.toml" "$home/.config/yazi/theme.toml"

echo 'Yazi theme checks passed.'
