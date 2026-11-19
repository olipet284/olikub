#!/bin/bash

APP_NAME="Cursor"
APP_DESCRIPTION="AI-powered code editor"
APP_DEFAULT=0
APP_BIN=cursor

app_installed() {
  [[ -x /opt/cursor.appimage ]] || dpkg_installed cursor
}

app_install() {
  cd /tmp
  sudo apt-get install -y jq fuse3 libfuse2t64
  curl -L "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable" | jq -r '.downloadUrl' | xargs curl -L -o cursor.appimage
  sudo mv cursor.appimage /opt/cursor.appimage
  sudo chmod +x /opt/cursor.appimage

  DESKTOP_FILE="/usr/share/applications/cursor.desktop"
  sudo bash -c "cat > $DESKTOP_FILE" <<EOL
[Desktop Entry]
Name=Cursor
Comment=AI-powered code editor
Exec=/opt/cursor.appimage --no-sandbox
Icon=$OLIKUB_PATH/launchers/icons/cursor.png
Type=Application
Categories=Development;IDE;
EOL
  cd -
}

app_uninstall() {
  sudo rm -f /opt/cursor.appimage /usr/share/applications/cursor.desktop
}
