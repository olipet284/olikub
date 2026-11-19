#!/bin/bash

APP_NAME="Alacritty"
APP_DESCRIPTION="GPU-powered terminal"
APP_DEFAULT=1
APP_BIN=alacritty

app_installed() {
  has_command alacritty || dpkg_installed alacritty
}

app_install() {
  sudo apt-get install -y alacritty

  mkdir -p ~/.config/alacritty
  cp "$OLIKUB_PATH/configs/alacritty.toml" ~/.config/alacritty/alacritty.toml
  cp "$OLIKUB_PATH/configs/alacritty/shared.toml" ~/.config/alacritty/shared.toml
  cp "$OLIKUB_PATH/configs/alacritty/pane.toml" ~/.config/alacritty/pane.toml
  cp "$OLIKUB_PATH/configs/alacritty/btop.toml" ~/.config/alacritty/btop.toml
  cp "$OLIKUB_PATH/themes/tokyo-night/alacritty.toml" ~/.config/alacritty/theme.toml
  cp "$OLIKUB_PATH/configs/alacritty/fonts/CaskaydiaMono.toml" ~/.config/alacritty/font.toml
  cp "$OLIKUB_PATH/configs/alacritty/font-size.toml" ~/.config/alacritty/font-size.toml

  # Migrate config format if needed
  alacritty migrate 2>/dev/null || true
  alacritty migrate -c ~/.config/alacritty/pane.toml 2>/dev/null || true
  alacritty migrate -c ~/.config/alacritty/btop.toml 2>/dev/null || true

  source "$OLIKUB_PATH/install/desktop/set-alacritty-default.sh"
}

app_uninstall() {
  apt_remove "$APP_NAME" alacritty
  echo "Kept Alacritty configuration in ~/.config/alacritty."
}
