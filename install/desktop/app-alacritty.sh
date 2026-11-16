#!/bin/bash

# Alacritty is a GPU-powered and highly extensible terminal. See https://alacritty.org/
sudo apt install -y alacritty
mkdir -p ~/.config/alacritty
cp ~/.local/share/olikub/configs/alacritty.toml ~/.config/alacritty/alacritty.toml
cp ~/.local/share/olikub/configs/alacritty/shared.toml ~/.config/alacritty/shared.toml
cp ~/.local/share/olikub/configs/alacritty/pane.toml ~/.config/alacritty/pane.toml
cp ~/.local/share/olikub/configs/alacritty/btop.toml ~/.config/alacritty/btop.toml
cp ~/.local/share/olikub/themes/tokyo-night/alacritty.toml ~/.config/alacritty/theme.toml
cp ~/.local/share/olikub/configs/alacritty/fonts/CaskaydiaMono.toml ~/.config/alacritty/font.toml
cp ~/.local/share/olikub/configs/alacritty/font-size.toml ~/.config/alacritty/font-size.toml

# Migrate config format if needed
alacritty migrate 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/pane.toml 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/btop.toml 2>/dev/null || true

source ~/.local/share/olikub/install/desktop/set-alacritty-default.sh
