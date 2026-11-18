#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home"
export HOME="$tmp/home" OLIKUB_PATH="$root" PATH="$tmp/bin:/usr/bin:/bin"
export GSETTINGS_LOG="$tmp/gsettings.log"

cat > "$tmp/bin/gsettings" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$GSETTINGS_LOG"
MOCK
chmod +x "$tmp/bin/gsettings"

run_hotkeys() {
  : > "$GSETTINGS_LOG"
  bash "$OLIKUB_PATH/install/desktop/set-gnome-hotkeys.sh"
}

export XDG_CONFIG_HOME="$tmp/config"
run_hotkeys

sample="$XDG_CONFIG_HOME/olikub/hotkeys/sample.sh"
[[ -f "$sample" ]]
cmp "$OLIKUB_PATH/configs/olikub/hotkeys/sample.sh" "$sample"
grep -F "switch-to-workspace-left ['<Super>Tab']" "$GSETTINGS_LOG" >/dev/null
grep -F "switch-to-workspace-right ['<Shift><Super>Tab']" "$GSETTINGS_LOG" >/dev/null
default_count=$(grep -c '^add_custom_keybinding ' "$sample")
applied_count=$(grep -c 'custom-keybinding:.* name ' "$GSETTINGS_LOG")
[[ "$applied_count" == "$default_count" ]]
grep -F ' name Open File Explorer' "$GSETTINGS_LOG" >/dev/null
grep -F ' name New Ghostty Window' "$GSETTINGS_LOG" >/dev/null
grep -F ' command ghostty' "$GSETTINGS_LOG" >/dev/null
grep -F ' name Choose Olikub Theme' "$GSETTINGS_LOG" >/dev/null
grep -F ' command ghostty -e bash -ic "olikub theme"' "$GSETTINGS_LOG" >/dev/null
grep -F ' name Lock Screen' "$GSETTINGS_LOG" >/dev/null
grep -F ' command loginctl lock-session' "$GSETTINGS_LOG" >/dev/null
grep -F ' binding <Control><Super>l' "$GSETTINGS_LOG" >/dev/null
grep -F ' name Open Teams' "$GSETTINGS_LOG" >/dev/null
grep -F ' binding <Shift><Super><Alt>t' "$GSETTINGS_LOG" >/dev/null

# Existing user files are retained rather than replaced with the sample.
printf '\n# user marker\n' >> "$sample"
run_hotkeys
grep -F '# user marker' "$sample" >/dev/null

# A dotfiles-style directory symlink is read in filename order.
mkdir -p "$tmp/dotfiles/olikub/hotkeys" "$tmp/config-linked/olikub"
cat > "$tmp/dotfiles/olikub/hotkeys/01-first.sh" <<'FIRST'
add_custom_keybinding 'First' 'true' '<Super>F1'
FIRST
cat > "$tmp/dotfiles/olikub/hotkeys/02-second.sh" <<'SECOND'
add_custom_keybinding 'Second' 'true' '<Super>F2'
SECOND
ln -s "$tmp/dotfiles/olikub/hotkeys" "$tmp/config-linked/olikub/hotkeys"
export XDG_CONFIG_HOME="$tmp/config-linked"
run_hotkeys
[[ -L "$XDG_CONFIG_HOME/olikub/hotkeys" ]]
grep -F 'custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name First' "$GSETTINGS_LOG" >/dev/null
grep -F 'custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name Second' "$GSETTINGS_LOG" >/dev/null
[[ $(grep -c 'custom-keybinding:.* name ' "$GSETTINGS_LOG") == 2 ]]

echo 'GNOME hotkey checks passed.'
