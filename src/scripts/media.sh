#!/bin/bash

# Media Applications Installation Script
# Installs browsers, media players, and streaming applications
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Main function
main() {
    update_apt_cache

    # Install Brave browser
    if [[ ! -f "/usr/share/keyrings/brave-browser-archive-keyring.gpg" ]]; then
        curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | \
            sudo gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg 2>>"$ERROR_LOG_FILE" || true
    fi

    if ! grep -q "brave-browser-apt-release" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
            sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
        update_apt_cache
    fi

    install_apt_packages "brave-browser"

    # Install VLC
    install_apt_packages "vlc"

    # Install Spotify via snap
    if command -v snap >/dev/null 2>&1; then
        sudo snap install spotify 2>>"$ERROR_LOG_FILE" || true
    fi

    # Install multimedia codecs
    local multimedia_packages=(
        "ffmpeg"
        "gstreamer1.0-plugins-bad"
        "gstreamer1.0-plugins-ugly"
        "gstreamer1.0-libav"
    )
    install_apt_packages "${multimedia_packages[@]}"

    # Install ubuntu-restricted-extras
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | \
        sudo debconf-set-selections
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-restricted-extras 2>>"$ERROR_LOG_FILE" || true
}

# Execute main function
main "$@"
