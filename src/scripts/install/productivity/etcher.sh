#!/bin/bash

etcher_path="$HOME/.local/bin/balenaEtcher.AppImage"
[[ -f "$etcher_path" ]] && exit 0
mkdir -p "$HOME/.local/bin"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y libfuse2
etcher_url=$(curl -s https://api.github.com/repos/balena-io/etcher/releases/latest | grep "browser_download_url.*x64.AppImage" | head -1 | cut -d '"' -f 4)
if [[ -n "$etcher_url" ]]; then
    curl -fsSL "$etcher_url" -o "$etcher_path" || true
    chmod +x "$etcher_path" || true
fi
