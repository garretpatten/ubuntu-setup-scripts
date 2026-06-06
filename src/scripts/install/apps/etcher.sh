#!/bin/bash

if command -v balena-etcher >/dev/null 2>&1; then
    exit 0
fi
if dpkg -s balena-etcher >/dev/null 2>&1; then
    exit 0
fi

etcher_deb="$TEMP_DIR/balena-etcher.deb"
etcher_tag=$(curl -fsSL https://api.github.com/repos/balena-io/etcher/releases/latest | \
    grep '"tag_name"' | head -1 | cut -d '"' -f 4)
etcher_version="${etcher_tag#v}"
etcher_url=""
if [[ -n "$etcher_version" ]]; then
    etcher_url="https://github.com/balena-io/etcher/releases/download/${etcher_tag}/balena-etcher_${etcher_version}_amd64.deb"
fi
if [[ -z "$etcher_url" ]]; then
    etcher_url=$(curl -fsSL https://api.github.com/repos/balena-io/etcher/releases/latest | \
        grep 'browser_download_url.*_amd64\.deb' | head -1 | cut -d '"' -f 4)
fi

if [[ -n "$etcher_url" ]] && curl -fsSL --retry 3 --retry-delay 2 "$etcher_url" -o "$etcher_deb"; then
    sudo dpkg -i "$etcher_deb" || true
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y --no-install-recommends || true
fi
if command -v balena-etcher >/dev/null 2>&1; then
    exit 0
fi
if dpkg -s balena-etcher >/dev/null 2>&1; then
    exit 0
fi

etcher_zip="$TEMP_DIR/balena-etcher.zip"
etcher_zip_url=""
if [[ -n "$etcher_version" ]]; then
    etcher_zip_url="https://github.com/balena-io/etcher/releases/download/${etcher_tag}/balenaEtcher-linux-x64-${etcher_version}.zip"
fi
if [[ -n "$etcher_zip_url" ]] && curl -fsSL --retry 3 --retry-delay 2 "$etcher_zip_url" -o "$etcher_zip"; then
    etcher_extract="$TEMP_DIR/balena-etcher-extract"
    rm -rf "$etcher_extract"
    mkdir -p "$etcher_extract"
    if unzip -q "$etcher_zip" -d "$etcher_extract"; then
        etcher_dir=$(find "$etcher_extract" -mindepth 1 -maxdepth 1 -type d | head -1)
        etcher_binary=""
        if [[ -n "$etcher_dir" && -f "$etcher_dir/balena-etcher" ]]; then
            etcher_binary="$etcher_dir/balena-etcher"
        else
            etcher_binary=$(find "$etcher_extract" -type f \( -name 'balena-etcher' -o -name '*.AppImage' \) | head -1)
        fi
        if [[ -n "$etcher_binary" ]]; then
            if [[ -n "$etcher_dir" ]]; then
                sudo rm -rf /opt/balena-etcher
                sudo mv "$etcher_dir" /opt/balena-etcher
                sudo ln -sf /opt/balena-etcher/balena-etcher /usr/local/bin/balena-etcher
            else
                install -m 755 "$etcher_binary" /usr/local/bin/balena-etcher || true
            fi
        fi
    fi
fi
