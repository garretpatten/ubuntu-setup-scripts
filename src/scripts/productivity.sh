#!/bin/bash

# Productivity Applications Installation Script
# Installs productivity tools, office applications, and utilities
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Main function
main() {
    update_apt_cache

    # Install LibreOffice
    local libreoffice_packages=(
        "libreoffice"
        "libreoffice-gtk3"
        "libreoffice-style-breeze"
    )
    install_apt_packages "${libreoffice_packages[@]}"

    # Install document tools
    local document_packages=(
        "evince"
        "okular"
        "pandoc"
        "texlive-latex-base"
        "ghostscript"
    )
    install_apt_packages "${document_packages[@]}"

    # Install communication tools via snap
    if command -v snap >/dev/null 2>&1; then
        sudo snap install zoom-client 2>>"$ERROR_LOG_FILE" || true
        sudo snap install discord 2>>"$ERROR_LOG_FILE" || true
        sudo snap install slack --classic 2>>"$ERROR_LOG_FILE" || true
    fi

    # Install Notion
    if ! grep -q "apt.fury.io/notion-repackaged" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        echo "deb [trusted=yes] https://apt.fury.io/notion-repackaged/ /" | \
            sudo tee /etc/apt/sources.list.d/notion-repackaged.list > /dev/null
        update_apt_cache
    fi
    sudo apt-get install -y notion-app 2>>"$ERROR_LOG_FILE" || true

    # Install Obsidian via Flatpak
    flatpak install -y flathub md.obsidian.Obsidian 2>>"$ERROR_LOG_FILE" || true

    # Install productivity tools
    local productivity_packages=(
        "thunderbird"
        "firefox"
        "keepassxc"
        "redshift"
        "flameshot"
        "tree"
        "ncdu"
    )
    install_apt_packages "${productivity_packages[@]}"

    # Install Balena Etcher
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

    # Install monitoring tools
    local monitoring_packages=(
        "htop"
        "iotop"
        "nethogs"
        "dstat"
        "lm-sensors"
    )
    install_apt_packages "${monitoring_packages[@]}"

    # Install file tools
    local file_packages=(
        "ranger"
        "mc"
        "p7zip-full"
        "unrar"
        "zip"
        "unzip"
    )
    install_apt_packages "${file_packages[@]}"

    # Configure Redshift
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
}

# Execute main function
main "$@"
