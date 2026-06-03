#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
multimedia_packages=(
    "ffmpeg" "gstreamer1.0-plugins-bad" "gstreamer1.0-plugins-ugly" "gstreamer1.0-libav"
)
install_apt_packages "${multimedia_packages[@]}"
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" 2>>"$ERROR_LOG_FILE" | \
    sudo debconf-set-selections 2>>"$ERROR_LOG_FILE" || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-restricted-extras 2>>"$ERROR_LOG_FILE" || true
