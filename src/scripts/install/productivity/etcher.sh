#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
etcher_dir="$HOME/.local/bin"
etcher_path="$etcher_dir/balenaEtcher.AppImage"
if [[ ! -f "$etcher_path" ]]; then
    ensure_directory "$etcher_dir"
    install_apt_packages "libfuse2"
    etcher_url=$(curl -s https://api.github.com/repos/balena-io/etcher/releases/latest 2>>"$ERROR_LOG_FILE" | grep "browser_download_url.*x64.AppImage" | head -1 | cut -d '"' -f 4)
    if [[ -n "$etcher_url" ]]; then
        download_file_safe "$etcher_url" "$etcher_path"
        if [[ -f "$etcher_path" ]] && [[ -s "$etcher_path" ]]; then
            chmod +x "$etcher_path" 2>>"$ERROR_LOG_FILE" || true
        fi
    fi
fi
