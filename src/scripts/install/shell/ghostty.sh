#!/bin/bash

install_script="$TEMP_DIR/ghostty-ubuntu-install.sh"
curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh -o "$install_script" || exit 0
sudo bash "$install_script" || true
