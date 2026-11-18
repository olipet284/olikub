#!/bin/bash

# Configure the bash shell using Olikub defaults
[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/olikub"
printf '%s\n' "$OLIKUB_PATH" > "${XDG_CONFIG_HOME:-$HOME/.config}/olikub/path"
mkdir -p "$HOME/.local/bin"
OLIKUB_LAUNCHER="$HOME/.local/bin/olikub"
if [[ ! -e "$OLIKUB_LAUNCHER" && ! -L "$OLIKUB_LAUNCHER" ]]; then
  cat > "$OLIKUB_LAUNCHER" <<'OLIKUB_LAUNCHER'
#!/usr/bin/env bash
OLIKUB_PATH_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/olikub/path"
if [[ -r "$OLIKUB_PATH_FILE" ]]; then
  IFS= read -r OLIKUB_PATH < "$OLIKUB_PATH_FILE"
else
  OLIKUB_PATH="${OLIKUB_PATH:-$HOME/.local/share/olikub}"
fi
export OLIKUB_PATH
exec "$OLIKUB_PATH/bin/olikub" "$@"
OLIKUB_LAUNCHER
  chmod +x "$OLIKUB_LAUNCHER"
fi
cp "$OLIKUB_PATH/configs/bashrc" ~/.bashrc
mkdir -p ~/dotfiles/bash

# Load the PATH for use later in the installers
source "$OLIKUB_PATH/defaults/bash/shell"

[ -f ~/.inputrc ] && mv ~/.inputrc ~/.inputrc.bak
# Configure the inputrc using Olikub defaults
cp "$OLIKUB_PATH/defaults/bash/inputrc" ~/.inputrc
