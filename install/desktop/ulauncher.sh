#!/bin/bash

sudo add-apt-repository universe -y
sudo add-apt-repository ppa:agornostal/ulauncher -y
sudo apt update
sudo apt install ulauncher -y

backup_dangling_symlink() {
  local path=$1 backup
  if [[ -L "$path" && ! -e "$path" ]]; then
    backup="$path.BAK-$(date +%Y%m%d-%H%M%S)"
    if [[ -e "$backup" || -L "$backup" ]]; then
      printf 'Backup already exists: %s\n' "$backup" >&2
      return 1
    fi
    mv -- "$path" "$backup"
    printf 'Backed up dangling symlink to %s\n' "$backup"
  fi
}

# Preserve existing settings; only launch and seed defaults on first setup.
AUTOSTART_FILE="$HOME/.config/autostart/ulauncher.desktop"
ULAUNCHER_SETTINGS_FILE="$HOME/.config/ulauncher/settings.json"
mkdir -p "$HOME/.config/autostart" "$HOME/.config/ulauncher"
backup_dangling_symlink "$AUTOSTART_FILE"
ULAUNCHER_SETTINGS_EXISTED=false
if [[ -e "$ULAUNCHER_SETTINGS_FILE" || -L "$ULAUNCHER_SETTINGS_FILE" ]]; then
  if [[ -L "$ULAUNCHER_SETTINGS_FILE" && ! -e "$ULAUNCHER_SETTINGS_FILE" ]]; then
    backup_dangling_symlink "$ULAUNCHER_SETTINGS_FILE"
  else
    ULAUNCHER_SETTINGS_EXISTED=true
  fi
fi
if [[ ! -e "$AUTOSTART_FILE" && ! -L "$AUTOSTART_FILE" ]]; then
  cp "$OLIKUB_PATH/configs/ulauncher.desktop" "$AUTOSTART_FILE"
fi
if [[ "$ULAUNCHER_SETTINGS_EXISTED" == false ]]; then
  gtk-launch ulauncher.desktop >/dev/null 2>&1
  sleep 2 # ensure enough time for ulauncher to set defaults
  cp "$OLIKUB_PATH/configs/ulauncher.json" "$ULAUNCHER_SETTINGS_FILE"
fi
