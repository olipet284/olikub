#!/bin/bash

cat <<EOF >~/.local/share/applications/Olikub.desktop
[Desktop Entry]
Version=1.0
Name=Olikub
Comment=Olikub Controls
Exec=alacritty --config-file /home/$USER/.config/alacritty/pane.toml --class=Olikub --title=Olikub -e olikub
Terminal=false
Type=Application
Icon=$OLIKUB_PATH/applications/icons/Olikub.png
Categories=GTK;
StartupNotify=false
EOF
