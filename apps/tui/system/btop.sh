#!/bin/bash

APP_NAME="btop"
APP_DESCRIPTION="Resource monitor for CPU, memory, disks and network"
APP_DEFAULT=1
APP_BIN=btop

app_installed() {
  has_command btop || dpkg_installed btop
}

app_install() {
  sudo apt-get install -y btop

  # Use Olikub btop config
  mkdir -p "$HOME/.config/btop/themes"
  BTOP_CONFIG="$HOME/.config/btop/btop.conf"
  if [[ ! -e "$BTOP_CONFIG" && ! -L "$BTOP_CONFIG" ]]; then
    cp "$OLIKUB_PATH/configs/btop.conf" "$BTOP_CONFIG"
  elif [[ -f "$BTOP_CONFIG" && ! -L "$BTOP_CONFIG" ]]; then
    for theme_file in "$OLIKUB_PATH"/themes/*/btop.theme; do
      [[ -f "$theme_file" ]] || continue
      theme_name=${theme_file%/btop.theme}
      theme_name=${theme_name##*/}
      if grep -Fqx "color_theme = \"$theme_name\"" "$BTOP_CONFIG"; then
        sed -i "s/^color_theme = \"$theme_name\"$/color_theme = \"olikub\"/" "$BTOP_CONFIG"
        break
      fi
    done
  fi
  cp "$OLIKUB_PATH/themes/tokyo-night/btop.theme" "$HOME/.config/btop/themes/olikub.theme"
}

app_uninstall() {
  apt_remove "$APP_NAME" btop
}
