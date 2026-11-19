#!/bin/bash

# Alt+F4 is very cumbersome
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>w']"

# Make it easy to maximize like you can fill left/right
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up', '<Super>f', '<Super>k']"

# Minimize window
gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>Down', '<Alt>m', '<Super>j']"

# Make it easy to resize undecorated windows
gsettings set org.gnome.desktop.wm.keybindings begin-resize "['<Super>BackSpace']"

# Make it easy to resize window with mouse
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true

# For keyboards that only have a start/stop button for music, like Logitech MX Keys Mini
gsettings set org.gnome.settings-daemon.plugins.media-keys next "['<Shift>AudioPlay']"

# Full-screen with title/navigation bar
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Shift>F11']"

# Use fixed workspaces instead of dynamic mode
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 5

# Disable the hotkeys in the Dash to Dock extension (most likely culprit)
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false

# Use super for workspaces
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']"

# Set window as always on top
gsettings set org.gnome.desktop.wm.keybindings toggle-above "['<Super>o']"

# Rotate workspaces
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super>Tab']"

# Disable default Alt+Space window menu so we can use it for Ulauncher
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "[]"

# Open Display Settings
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Primary><Alt>d', '<Super>d']"

# Define custom keybindings as: name, command, binding.
CUSTOM_NAMES=()
CUSTOM_COMMANDS=()
CUSTOM_BINDINGS=()

add_custom_keybinding() {
  CUSTOM_NAMES+=("$1")
  CUSTOM_COMMANDS+=("$2")
  CUSTOM_BINDINGS+=("$3")
}

HOTKEYS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/olikub/hotkeys"
if [[ -L "$HOTKEYS_DIR" && ! -e "$HOTKEYS_DIR" ]]; then
  printf 'Hotkeys directory is a dangling symlink: %s\n' "$HOTKEYS_DIR" >&2
  exit 1
fi
if [[ ! -e "$HOTKEYS_DIR" ]]; then
  mkdir -p "$HOTKEYS_DIR"
  cp "$OLIKUB_PATH/configs/olikub/hotkeys/sample.sh" "$HOTKEYS_DIR/sample.sh"
elif [[ ! -d "$HOTKEYS_DIR" ]]; then
  printf 'Hotkeys path is not a directory: %s\n' "$HOTKEYS_DIR" >&2
  exit 1
fi

# Files can be symlinked from a dotfiles repo; glob order gives stable numbering.
for HOTKEY_FILE in "$HOTKEYS_DIR"/*.sh; do
  [[ -f "$HOTKEY_FILE" ]] || continue
  source "$HOTKEY_FILE"
done

CUSTOM_KEYBINDINGS=""
for i in "${!CUSTOM_NAMES[@]}"; do
  CUSTOM_KEYBINDINGS="$CUSTOM_KEYBINDINGS '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$i/',"
done
CUSTOM_KEYBINDINGS="[${CUSTOM_KEYBINDINGS%,}]"
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$CUSTOM_KEYBINDINGS"

for i in "${!CUSTOM_NAMES[@]}"; do
  KEY_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$i/"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$KEY_PATH" name "${CUSTOM_NAMES[$i]}"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$KEY_PATH" command "${CUSTOM_COMMANDS[$i]}"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$KEY_PATH" binding "${CUSTOM_BINDINGS[$i]}"
done

# Lock Screen
gsettings set org.gnome.desktop.screensaver lock-enabled true
gsettings set org.gnome.desktop.session idle-delay 1800
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Primary><Super><Alt>l']"
