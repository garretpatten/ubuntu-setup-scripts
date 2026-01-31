#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

local libreoffice_packages=(
    "libreoffice"
    "libreoffice-gtk3"
    "libreoffice-style-breeze"
)
install_apt_packages "${libreoffice_packages[@]}"

if command -v snap >/dev/null 2>&1; then
    sudo snap install zoom-client 2>>"$ERROR_LOG_FILE" || true
fi

if ! grep -q "apt.fury.io/notion-repackaged" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "deb [trusted=yes] https://apt.fury.io/notion-repackaged/ /" | \
        sudo tee /etc/apt/sources.list.d/notion-repackaged.list > /dev/null
    update_apt_cache
fi
sudo apt-get install -y notion-app 2>>"$ERROR_LOG_FILE" || true

flatpak install -y flathub org.standardnotes.standardnotes 2>>"$ERROR_LOG_FILE" || true

local productivity_packages=(
    "keepassxc"
    "redshift"
    "flameshot"
)
install_apt_packages "${productivity_packages[@]}"

local etcher_dir="$HOME/.local/bin"
local etcher_path="$etcher_dir/balenaEtcher.AppImage"
if [[ ! -f "$etcher_path" ]]; then
    ensure_directory "$etcher_dir"
    install_apt_packages "libfuse2"
    download_file_safe "https://github.com/balena-io/etcher/releases/latest/download/balenaEtcher-1.18.11-x64.AppImage" "$etcher_path"
    if [[ -f "$etcher_path" ]]; then
        chmod +x "$etcher_path"
        ensure_directory "$HOME/.local/share/applications"
        cat > "$HOME/.local/share/applications/balena-etcher.desktop" << EOF
[Desktop Entry]
Name=balenaEtcher
Comment=Flash OS images to SD cards and USB drives
Exec=$etcher_path
Icon=balena-etcher
Type=Application
Categories=System;Utility;
EOF
    fi
fi

local redshift_config="$HOME/.config/redshift.conf"
if [[ ! -f "$redshift_config" ]]; then
    ensure_directory "$HOME/.config"
    cat > "$redshift_config" << 'EOF'
[redshift]
temp-day=6500
temp-night=4500
fade=1
gamma=0.8
location-provider=manual
adjustment-method=randr

[manual]
lat=40.7
lon=-74.0
EOF
fi
