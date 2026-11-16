#!/bin/bash

if ! command -v uv &> /dev/null; then
  source ~/.local/share/olikub/install/terminal/optional/uv.sh
fi

uv tool install jiratui --with "textual[syntax]>=6.4.0,<8.0.0" --force
