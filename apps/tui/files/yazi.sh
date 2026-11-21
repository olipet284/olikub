#!/bin/bash

APP_NAME="Yazi"
APP_DESCRIPTION="Blazing fast terminal file manager"
APP_DEFAULT=1
APP_BIN=yazi

app_installed() {
  has_command yazi || dpkg_installed yazi
}

app_install() {
  local target=x86_64-unknown-linux-gnu

  cd /tmp
  curl -sLo yazi.zip "https://github.com/sxyazi/yazi/releases/latest/download/yazi-${target}.zip"
  unzip -q yazi.zip
  sudo install "yazi-${target}/yazi" "yazi-${target}/ya" /usr/local/bin
  if [ -d "yazi-${target}/completions" ]; then
    sudo mkdir -p /usr/share/bash-completion/completions
    sudo install -m 644 "yazi-${target}/completions/yazi.bash" /usr/share/bash-completion/completions/yazi
    sudo install -m 644 "yazi-${target}/completions/ya.bash" /usr/share/bash-completion/completions/ya
  fi
  rm -rf yazi.zip "yazi-${target}"
  cd -

  # Seed the non-theme config once, then apply the active Olikub theme.
  mkdir -p "$HOME/.config/yazi"
  if [ ! -e "$HOME/.config/yazi/yazi.toml" ]; then
    cp "$OLIKUB_PATH/configs/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
  fi

  local theme
  theme=$(cat "${XDG_STATE_HOME:-$HOME/.local/state}/olikub/theme" 2>/dev/null || true)
  [[ -n "$theme" && -d "$OLIKUB_PATH/themes/$theme" ]] || theme=tokyo-night
  cp "$OLIKUB_PATH/themes/$theme/yazi-theme.toml" "$HOME/.config/yazi/theme.toml"
}

app_uninstall() {
  remove_local_binary "$APP_NAME" /usr/local/bin/yazi
  remove_local_binary "$APP_NAME" /usr/local/bin/ya
  sudo rm -f /usr/share/bash-completion/completions/yazi /usr/share/bash-completion/completions/ya
  echo "Kept Yazi configuration in ~/.config/yazi."
}
