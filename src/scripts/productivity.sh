#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

libreoffice_packages=(
    "libreoffice"
    "libreoffice-gtk3"
    "libreoffice-style-breeze"
)
install_apt_packages "${libreoffice_packages[@]}"

if command -v snap >/dev/null 2>&1; then
    sudo snap install zoom-client 2>>"$ERROR_LOG_FILE" || true
fi

if ! grep -q "apt.fury.io/notion-repackaged" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "deb [trusted=yes] https://apt.fury.io/notion-repackaged/ /" 2>>"$ERROR_LOG_FILE" | \
        sudo tee /etc/apt/sources.list.d/notion-repackaged.list > /dev/null 2>>"$ERROR_LOG_FILE" || true
    update_apt_cache
fi
sudo apt-get install -y notion-app 2>>"$ERROR_LOG_FILE" || true

flatpak install -y flathub org.standardnotes.standardnotes 2>>"$ERROR_LOG_FILE" || true

productivity_packages=(
    "keepassxc"
    "redshift"
    "flameshot"
)
install_apt_packages "${productivity_packages[@]}"

etcher_dir="$HOME/.local/bin"
etcher_path="$etcher_dir/balenaEtcher.AppImage"
if [[ ! -f "$etcher_path" ]]; then
    ensure_directory "$etcher_dir"
    install_apt_packages "libfuse2"
    download_file_safe "https://github.com/balena-io/etcher/releases/latest/download/balenaEtcher-1.18.11-x64.AppImage" "$etcher_path"
    if [[ -f "$etcher_path" ]]; then
        chmod +x "$etcher_path" 2>>"$ERROR_LOG_FILE" || true
    fi
fi
