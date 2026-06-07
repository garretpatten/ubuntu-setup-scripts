#!/bin/bash

install_dir="${HOME}/.local/bin"
install_script="$TEMP_DIR/oh-my-posh-install.sh"
mkdir -p "$install_dir"
curl -fsSL https://ohmyposh.dev/install.sh -o "$install_script" || exit 0
bash "$install_script" -d "$install_dir" 2>/dev/null || true
