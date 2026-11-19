#!/bin/bash

cat > "$HOME/.local/share/applications/Olikub.desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=Olikub
Comment=Olikub Controls
Exec=alacritty --config-file "$HOME/.config/alacritty/pane.toml" --class=Olikub --title=Olikub -e bash -ic olikub
Terminal=false
Type=Application
Icon=$OLIKUB_PATH/launchers/icons/Olikub.png
Categories=Utility;
StartupNotify=false
EOF
