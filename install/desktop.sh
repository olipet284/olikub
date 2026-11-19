#!/bin/bash

# Run desktop installers
for installer in "$OLIKUB_PATH"/install/desktop/*.sh; do source "$installer"; done
