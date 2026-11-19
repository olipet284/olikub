#!/bin/bash

# Needed for all installers
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl git unzip

# Install required tooling before optional apps (mise, uv, libraries).
# Gum was already installed for the first-run choices.
for installer in "$OLIKUB_PATH"/install/terminal/required/*.sh; do
  [[ "$(basename "$installer")" == "app-gum.sh" ]] && continue
  source "$installer"
done

# Run terminal installers
for installer in "$OLIKUB_PATH"/install/terminal/*.sh; do source "$installer"; done
