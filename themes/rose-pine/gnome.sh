#!/bin/bash

OLIKUB_THEME_COLOR="red"
OLIKUB_THEME_BACKGROUND="rose-pine/background.jpg"
source "$OLIKUB_PATH/themes/set-gnome-theme.sh"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
