#!/bin/bash

envsubst < "$OLIKUB_PATH/configs/xcompose" > ~/.XCompose
ibus restart
gsettings set org.gnome.desktop.input-sources xkb-options "['compose:caps']"
