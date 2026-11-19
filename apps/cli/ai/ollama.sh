#!/bin/bash

APP_NAME="Ollama"
APP_DESCRIPTION="Run large language models locally"
APP_DEFAULT=0
APP_BIN=ollama

app_installed() {
  has_command ollama || dpkg_installed ollama
}

app_install() {
  curl -fsSL https://ollama.com/install.sh | sh
}

app_uninstall() {
  if has_command ollama; then
    sudo systemctl stop ollama 2>/dev/null || true
    sudo systemctl disable ollama 2>/dev/null || true
    sudo rm -f /etc/systemd/system/ollama.service
    sudo rm -f "$(command -v ollama)"
    echo "Kept downloaded models in /usr/share/ollama and the ollama service user."
  else
    echo "$APP_NAME is installed outside the supported Ollama installer; leaving it in place."
  fi
}
