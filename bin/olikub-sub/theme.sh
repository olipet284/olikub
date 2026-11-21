#!/bin/bash

THEME_NAMES=("Tokyo Night" "Catppuccin" "Nord" "Everforest" "Gruvbox" "Kanagawa" "Ristretto" "Rose Pine" "Matte Black" "Osaka Jade")
THEME=$(gum choose "${THEME_NAMES[@]}" "<< Back" --header "Choose your theme" --height 12 | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

copy_theme_file() {
  local source=$1 destination=$2 temporary
  if [[ -L "$destination" && ! -e "$destination" ]]; then
    temporary=$(mktemp "${destination}.XXXXXX") || return 1
    if cp "$source" "$temporary" && mv -f -- "$temporary" "$destination"; then
      return 0
    fi
    rm -f -- "$temporary"
    return 1
  fi
  cp "$source" "$destination"
}

if [ -n "$THEME" ] && [ "$THEME" != "<<-back" ]; then
  cp "$OLIKUB_PATH/themes/$THEME/alacritty.toml" ~/.config/alacritty/theme.toml
  copy_theme_file "$OLIKUB_PATH/themes/$THEME/zellij.kdl" "$HOME/.config/zellij/themes/$THEME.kdl" || exit 1
  sed -i "s/theme \".*\"/theme \"$THEME\"/g" ~/.config/zellij/config.kdl
  if [ -d "$HOME/.config/nvim" ]; then
    cp "$OLIKUB_PATH/themes/$THEME/neovim.lua" ~/.config/nvim/lua/plugins/theme.lua
  fi

  if [ -f "$OLIKUB_PATH/themes/$THEME/btop.theme" ]; then
    cp "$OLIKUB_PATH/themes/$THEME/btop.theme" "$HOME/.config/btop/themes/olikub.theme"
  fi

  if [ -d "$HOME/.config/yazi" ]; then
    copy_theme_file "$OLIKUB_PATH/themes/$THEME/yazi-theme.toml" "$HOME/.config/yazi/theme.toml" || exit 1
  fi

  source "$OLIKUB_PATH/themes/$THEME/ghostty.sh"
  source "$OLIKUB_PATH/themes/$THEME/gnome.sh"
  source "$OLIKUB_PATH/themes/$THEME/tophat.sh"
  source "$OLIKUB_PATH/themes/$THEME/vscode.sh"

  # Forgo setting the Chrome theme until we might find a less disruptive way of doing it.
  # Having to quit Chrome, and all Chrome-based apps, is too much of an inposition.
  # source $OLIKUB_PATH/themes/$THEME/chrome.sh
fi

source "$OLIKUB_PATH/bin/olikub-sub/menu.sh"
