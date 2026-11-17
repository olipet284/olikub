#!/bin/bash

sudo echo "Running upgrade migration..."

# Add rustc and pgsql client libs
source "$OLIKUB_PATH/install/terminal/libraries.sh"

# Set name and class for desktop files
source "$OLIKUB_PATH/applications/About.sh"
source "$OLIKUB_PATH/applications/Activity.sh"
source "$OLIKUB_PATH/applications/Basecamp.sh"
source "$OLIKUB_PATH/applications/HEY.sh"
source "$OLIKUB_PATH/applications/Docker.sh"
source "$OLIKUB_PATH/applications/Neovim.sh"
source "$OLIKUB_PATH/applications/Olikub.sh"
source "$OLIKUB_PATH/applications/WhatsApp.sh"
