#!/bin/bash

if command -v balena-etcher >/dev/null 2>&1; then
    exit 0
fi

etcher_deb="$TEMP_DIR/balena-etcher.deb"
etcher_url=$(curl -s https://api.github.com/repos/balena-io/etcher/releases/latest | \
    grep "browser_download_url.*amd64.deb" | head -1 | cut -d '"' -f 4)
if [[ -n "$etcher_url" ]]; then
    if curl -fsSL "$etcher_url" -o "$etcher_deb"; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$etcher_deb" || true
    fi
fi
