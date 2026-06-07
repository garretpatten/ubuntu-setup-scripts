#!/bin/bash

if command -v balena-etcher >/dev/null 2>&1; then
    exit 0
fi
if dpkg -s balena-etcher >/dev/null 2>&1; then
    exit 0
fi

etcher_deb="$TEMP_DIR/balena-etcher.deb"
etcher_tag=$(curl -fsSL https://api.github.com/repos/balena-io/etcher/releases/latest 2>/dev/null | \
    grep '"tag_name"' | head -1 | cut -d '"' -f 4)
if [[ -z "$etcher_tag" ]]; then
    etcher_tag="v2.1.6"
fi
etcher_version="${etcher_tag#v}"
etcher_url="https://github.com/balena-io/etcher/releases/download/${etcher_tag}/balena-etcher_${etcher_version}_amd64.deb"

if curl -fsSL --retry 3 --retry-delay 2 "$etcher_url" -o "$etcher_deb"; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$etcher_deb" || true
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y --no-install-recommends || true
fi
if command -v balena-etcher >/dev/null 2>&1; then
    exit 0
fi
if dpkg -s balena-etcher >/dev/null 2>&1; then
    exit 0
fi

etcher_zip="$TEMP_DIR/balena-etcher.zip"
etcher_zip_url="https://github.com/balena-io/etcher/releases/download/${etcher_tag}/balenaEtcher-linux-x64-${etcher_version}.zip"
if curl -fsSL --retry 3 --retry-delay 2 "$etcher_zip_url" -o "$etcher_zip"; then
    etcher_extract="$TEMP_DIR/balena-etcher-extract"
    rm -rf "$etcher_extract"
    mkdir -p "$etcher_extract"
    if unzip -q "$etcher_zip" -d "$etcher_extract"; then
        etcher_dir=$(find "$etcher_extract" -mindepth 1 -maxdepth 1 -type d | head -1)
        if [[ -n "$etcher_dir" && -f "$etcher_dir/balena-etcher" ]]; then
            sudo rm -rf /opt/balena-etcher
            sudo mv "$etcher_dir" /opt/balena-etcher
            sudo ln -sf /opt/balena-etcher/balena-etcher /usr/local/bin/balena-etcher
        fi
    fi
fi
