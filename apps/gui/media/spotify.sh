#!/bin/bash

APP_NAME="Spotify"
APP_DESCRIPTION="Music streaming client"
APP_DEFAULT=0
APP_BIN=spotify

app_installed() {
  dpkg_installed spotify-client || has_command spotify
}

app_install() {
  if [ ! -f /etc/apt/sources.list.d/spotify.list ]; then
    [ -f /etc/apt/trusted.gpg.d/spotify.gpg ] && sudo rm /etc/apt/trusted.gpg.d/spotify.gpg
    curl -sS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/spotify.gpg] https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
  fi

  sudo apt-get update
  sudo apt-get install -y spotify-client
}

app_uninstall() {
  apt_remove "$APP_NAME" spotify-client
  sudo rm -f /etc/apt/sources.list.d/spotify.list /etc/apt/trusted.gpg.d/spotify.gpg
}
