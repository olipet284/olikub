#!/bin/bash

APP_NAME="Geekbench"
APP_DESCRIPTION="CPU benchmarking tool"
APP_DEFAULT=0
APP_BIN=geekbench6

app_installed() {
  has_command geekbench6 || [[ -x /usr/local/geekbench6/geekbench6 ]]
}

app_install() {
  GB_VERSION="6.4.0"
  cd /tmp
  gum spin --title "Downloading Geekbench $GB_VERSION..." -- \
    curl -sLo geekbench.tar.gz "https://cdn.geekbench.com/Geekbench-${GB_VERSION}-Linux.tar.gz"
  gum spin --title "Extracting Geekbench $GB_VERSION..." -- \
    tar -xzf geekbench.tar.gz
  sudo mv "Geekbench-${GB_VERSION}-Linux" /usr/local/geekbench6
  sudo ln -sf /usr/local/geekbench6/geekbench6 /usr/local/bin/geekbench6
  rm -rf Geekbench* geekbench.tar.gz
  cd -
  echo "Run as geekbench6 from the terminal"
}

app_uninstall() {
  sudo rm -rf /usr/local/geekbench6
  sudo rm -f /usr/local/bin/geekbench6
}
