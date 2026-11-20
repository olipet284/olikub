#!/bin/bash

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
gsettings set org.gnome.desktop.interface gtk-theme "Yaru-$OLIKUB_THEME_COLOR-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru-$OLIKUB_THEME_COLOR"
gsettings set org.gnome.desktop.interface accent-color "$OLIKUB_THEME_COLOR" 2>/dev/null || true

"$OLIKUB_PATH/bin/olikub-sub/wallpaper.sh" apply "$OLIKUB_THEME_NAME" >/dev/null
