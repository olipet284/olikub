#!/bin/bash

sudo apt install -y gnome-shell-extension-manager gir1.2-gtop-2.0 gir1.2-clutter-1.0
pipx install gnome-extensions-cli --system-site-packages
PIPX_HOME_DIR=$(pipx environment --value PIPX_HOME)
GEXT="$PIPX_HOME_DIR/venvs/gnome-extensions-cli/bin/gext"
if [[ ! -x "$GEXT" ]]; then
  printf 'gext executable not found in pipx environment: %s\n' "$GEXT" >&2
  exit 1
fi

# Turn off default Ubuntu extensions
gnome-extensions disable tiling-assistant@ubuntu.com
gnome-extensions disable ubuntu-appindicators@ubuntu.com
gnome-extensions disable ubuntu-dock@ubuntu.com
gnome-extensions disable ding@rastersoft.com

# Pause to assure user is ready to accept confirmations
gum confirm "To install Gnome extensions, you need to accept some confirmations. Ready?"

# Install media codex
sudo apt -y install ubuntu-restricted-extras

# Install new extensions
"$GEXT" install tactile@lundal.io
"$GEXT" install just-perfection-desktop@just-perfection
"$GEXT" install blur-my-shell@aunetx
"$GEXT" install space-bar@luchrioh
"$GEXT" install undecorate@sun.wxg@gmail.com
"$GEXT" install tophat@fflewddur.github.io
"$GEXT" install AlphabeticalAppGrid@stuarthayhurst

# Compile extension schemas privately to avoid collisions with system schemas.
OLIKUB_SCHEMA_DIR=$(mktemp -d "${TMPDIR:-/tmp}/olikub-gnome-schemas.XXXXXX")
cp "$HOME/.local/share/gnome-shell/extensions/tactile@lundal.io/schemas/org.gnome.shell.extensions.tactile.gschema.xml" "$OLIKUB_SCHEMA_DIR/"
cp "$HOME/.local/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml" "$OLIKUB_SCHEMA_DIR/"
cp "$HOME/.local/share/gnome-shell/extensions/blur-my-shell@aunetx/schemas/org.gnome.shell.extensions.blur-my-shell.gschema.xml" "$OLIKUB_SCHEMA_DIR/"
cp "$HOME/.local/share/gnome-shell/extensions/space-bar@luchrioh/schemas/"*.gschema.xml "$OLIKUB_SCHEMA_DIR/"
cp "$HOME/.local/share/gnome-shell/extensions/tophat@fflewddur.github.io/schemas/org.gnome.shell.extensions.tophat.gschema.xml" "$OLIKUB_SCHEMA_DIR/"
cp "$HOME/.local/share/gnome-shell/extensions/AlphabeticalAppGrid@stuarthayhurst/schemas/org.gnome.shell.extensions.alphabetical-app-grid.gschema.xml" "$OLIKUB_SCHEMA_DIR/"
glib-compile-schemas "$OLIKUB_SCHEMA_DIR"
gsettings_ext() { GSETTINGS_SCHEMA_DIR="$OLIKUB_SCHEMA_DIR" command gsettings "$@"; }

# Configure Tactile
gsettings_ext set org.gnome.shell.extensions.tactile col-0 1
gsettings_ext set org.gnome.shell.extensions.tactile col-1 2
gsettings_ext set org.gnome.shell.extensions.tactile col-2 1
gsettings_ext set org.gnome.shell.extensions.tactile col-3 0
gsettings_ext set org.gnome.shell.extensions.tactile row-0 1
gsettings_ext set org.gnome.shell.extensions.tactile row-1 1
gsettings_ext set org.gnome.shell.extensions.tactile gap-size 0
gsettings_ext set org.gnome.shell.extensions.tactile show-settings "['<Control><Super>t']"

# Configure Just Perfection
gsettings_ext set org.gnome.shell.extensions.just-perfection animation 2
gsettings_ext set org.gnome.shell.extensions.just-perfection dash-app-running true
gsettings_ext set org.gnome.shell.extensions.just-perfection workspace true
gsettings_ext set org.gnome.shell.extensions.just-perfection workspace-popup false

# Configure Blur My Shell
gsettings_ext set org.gnome.shell.extensions.blur-my-shell.appfolder blur false
gsettings_ext set org.gnome.shell.extensions.blur-my-shell.lockscreen blur false
gsettings_ext set org.gnome.shell.extensions.blur-my-shell.screenshot blur false
gsettings_ext set org.gnome.shell.extensions.blur-my-shell.window-list blur false
gsettings_ext set org.gnome.shell.extensions.blur-my-shell.panel blur false
gsettings_ext set org.gnome.shell.extensions.blur-my-shell.overview blur true
gsettings_ext set org.gnome.shell.extensions.blur-my-shell.overview pipeline 'pipeline_default'
gsettings_ext set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true
gsettings_ext set org.gnome.shell.extensions.blur-my-shell.dash-to-dock brightness 0.6
gsettings_ext set org.gnome.shell.extensions.blur-my-shell.dash-to-dock sigma 30
gsettings_ext set org.gnome.shell.extensions.blur-my-shell.dash-to-dock static-blur true
gsettings_ext set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 0

# Configure Space Bar
gsettings_ext set org.gnome.shell.extensions.space-bar.behavior smart-workspace-names false
gsettings_ext set org.gnome.shell.extensions.space-bar.shortcuts enable-activate-workspace-shortcuts false
gsettings_ext set org.gnome.shell.extensions.space-bar.shortcuts enable-move-to-workspace-shortcuts true
gsettings_ext set org.gnome.shell.extensions.space-bar.shortcuts open-menu "@as []"

# Configure TopHat
gsettings_ext set org.gnome.shell.extensions.tophat show-icons true
gsettings_ext set org.gnome.shell.extensions.tophat show-cpu true
gsettings_ext set org.gnome.shell.extensions.tophat show-disk false
gsettings_ext set org.gnome.shell.extensions.tophat show-mem true
gsettings_ext set org.gnome.shell.extensions.tophat show-fs false
gsettings_ext set org.gnome.shell.extensions.tophat network-usage-unit bits

# Configure AlphabeticalAppGrid
gsettings_ext set org.gnome.shell.extensions.alphabetical-app-grid folder-order-position 'end'

unset -f gsettings_ext
rm -rf -- "$OLIKUB_SCHEMA_DIR"
unset OLIKUB_SCHEMA_DIR
