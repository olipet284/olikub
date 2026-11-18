#!/bin/bash

# This script installs btop, a resource monitor that shows usage and stats for processor, memory, disks, network and processes.
sudo apt install -y btop

# Use Olikub btop config
mkdir -p ~/.config/btop/themes
cp "$OLIKUB_PATH/configs/btop.conf" ~/.config/btop/btop.conf
cp "$OLIKUB_PATH/themes/tokyo-night/btop.theme" ~/.config/btop/themes/tokyo-night.theme
