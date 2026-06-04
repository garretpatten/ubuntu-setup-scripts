#!/bin/bash

install_script="$TEMP_DIR/oh-my-posh-install.sh"
curl -fsSL https://ohmyposh.dev/install.sh -o "$install_script" || exit 0
bash "$install_script" -d "${HOME}/.local/bin" 2>/dev/null || true

themes_dir="/usr/share/oh-my-posh/themes"
if [[ ! -d "$themes_dir" ]] || [[ -z "$(ls -A "$themes_dir" 2>/dev/null)" ]]; then
    repo="$TEMP_DIR/oh-my-posh-repo"
    if [[ ! -d "$repo" ]]; then
        git clone https://github.com/JanDeDobbeleer/oh-my-posh.git "$repo" || true
    fi
    sudo mkdir -p "$themes_dir"
    if [[ -d "$repo/themes" ]]; then
        sudo cp -r "$repo/themes/"* "$themes_dir/" || true
    fi
fi
