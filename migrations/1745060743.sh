#!/bin/bash

cp ~/.local/share/olikub/configs/alacritty/shared.toml ~/.config/alacritty/shared.toml
cp ~/.local/share/olikub/configs/alacritty/pane.toml ~/.config/alacritty/pane.toml
cp ~/.local/share/olikub/configs/alacritty/btop.toml ~/.config/alacritty/btop.toml
cp ~/.local/share/olikub/configs/alacritty.toml ~/.config/alacritty/alacritty.toml

source $OLIKUB_PATH/applications/About.sh
source $OLIKUB_PATH/applications/Activity.sh
source $OLIKUB_PATH/applications/Neovim.sh
source $OLIKUB_PATH/applications/Docker.sh
source $OLIKUB_PATH/applications/Olikub.sh

alacritty migrate 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/pane.toml 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/btop.toml 2>/dev/null || true
