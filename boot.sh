#!/bin/bash

set -e

ascii_art=' ▄██████▄    ▄▄▄▄███▄▄▄▄      ▄████████    ▄█   ▄█▄ ███    █▄  ▀█████████▄
███    ███ ▄██▀▀▀███▀▀▀██▄   ███    ███   ███ ▄███▀ ███    ███   ███    ███
███    ███ ███   ███   ███   ███    ███   ███▐██▀   ███    ███   ███    ███
███    ███ ███   ███   ███   ███    ███  ▄█████▀    ███    ███  ▄███▄▄▄██▀
███    ███ ███   ███   ███ ▀███████████ ▀▀█████▄    ███    ███ ▀▀███▀▀▀██▄
███    ███ ███   ███   ███   ███    ███   ███▐██▄   ███    ███   ███    ██▄
███    ███ ███   ███   ███   ███    ███   ███ ▀███▄ ███    ███   ███    ███
 ▀██████▀   ▀█   ███   █▀    ███    █▀    ███   ▀█▀ ████████▀  ▄█████████▀
                                          ▀
'

echo -e "$ascii_art"
echo "=> Olikub is for fresh Ubuntu 26.04+ installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Cloning Olikub..."
rm -rf ~/.local/share/olikub
git clone --branch main --single-branch https://github.com/olipet284/olikub.git ~/.local/share/olikub >/dev/null

echo "Installation starting..."
source ~/.local/share/olikub/install.sh
