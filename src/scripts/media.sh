#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

if [[ ! -f "/usr/share/keyrings/brave-browser-archive-keyring.gpg" ]]; then
    curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg 2>>"$ERROR_LOG_FILE" | \
        sudo gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg 2>>"$ERROR_LOG_FILE" || true
fi

if ! grep -q "brave-browser-apt-release" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" 2>>"$ERROR_LOG_FILE" | \
        sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null 2>>"$ERROR_LOG_FILE" || true
    update_apt_cache
fi

install_apt_packages "brave-browser"

install_apt_packages "vlc"

if command -v snap >/dev/null 2>&1; then
    sudo snap install spotify 2>>"$ERROR_LOG_FILE" || true
fi

local multimedia_packages=(
    "ffmpeg"
    "gstreamer1.0-plugins-bad"
    "gstreamer1.0-plugins-ugly"
    "gstreamer1.0-libav"
)
install_apt_packages "${multimedia_packages[@]}"

echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" 2>>"$ERROR_LOG_FILE" | \
    sudo debconf-set-selections 2>>"$ERROR_LOG_FILE" || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-restricted-extras 2>>"$ERROR_LOG_FILE" || true
