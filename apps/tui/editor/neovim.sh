#!/bin/bash

APP_NAME="Neovim"
APP_DESCRIPTION="Modal text editor"
APP_DEFAULT=1
APP_BIN=nvim

app_installed() {
  has_command nvim || dpkg_installed neovim
}

app_install() {
  cd /tmp
  wget -O nvim.tar.gz "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"
  tar -xf nvim.tar.gz
  sudo install nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
  sudo cp -R nvim-linux-x86_64/lib /usr/local/
  sudo cp -R nvim-linux-x86_64/share /usr/local/
  rm -rf nvim-linux-x86_64 nvim.tar.gz
  cd -

  # Install luarocks and tree-sitter-cli to resolve lazyvim :checkhealth warnings
  sudo apt-get install -y luarocks tree-sitter-cli

  # Only attempt to set configuration if Neovim has never been run
  if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git

    mkdir -p ~/.config/nvim/plugin/after
    cp "$OLIKUB_PATH/configs/neovim/transparency.lua" ~/.config/nvim/plugin/after/
    cp "$OLIKUB_PATH/themes/tokyo-night/neovim.lua" ~/.config/nvim/lua/plugins/theme.lua
    cp "$OLIKUB_PATH/configs/neovim/snacks-animated-scrolling-off.lua" ~/.config/nvim/lua/plugins/
    echo "vim.opt.relativenumber = false" >>~/.config/nvim/lua/config/options.lua
    cp "$OLIKUB_PATH/configs/neovim/lazyvim.json" ~/.config/nvim/
  fi

  # Replace desktop launcher with one running inside Alacritty
  if [[ -d ~/.local/share/applications ]]; then
    sudo rm -rf /usr/share/applications/nvim.desktop
    sudo rm -rf /usr/local/share/applications/nvim.desktop
    source "$OLIKUB_PATH/launchers/Neovim.sh"
  fi
}

app_uninstall() {
  if [[ -x /usr/local/bin/nvim ]]; then
    sudo rm -f /usr/local/bin/nvim
    sudo rm -rf /usr/local/lib/nvim /usr/local/share/nvim
    rm -f ~/.local/share/applications/Neovim.desktop
  else
    apt_remove "$APP_NAME" neovim neovim-runtime
  fi
  echo "Kept Neovim configuration in ~/.config/nvim and related data."
}
