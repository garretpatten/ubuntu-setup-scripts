#!/bin/bash

# shellcheck source=../utils.sh
source "$(dirname "$0")/../utils.sh"

update_apt_cache

sudo apt-get upgrade -y 2>>"$ERROR_LOG_FILE" || true
sudo apt-get autoremove -y 2>>"$ERROR_LOG_FILE" || true
sudo apt-get autoclean 2>>"$ERROR_LOG_FILE" || true

if command -v docker >/dev/null 2>&1; then
    sudo systemctl enable docker.service 2>>"$ERROR_LOG_FILE" || true
    sudo systemctl start docker.service 2>>"$ERROR_LOG_FILE" || true
    sudo usermod -aG docker "$USER" 2>>"$ERROR_LOG_FILE" || true
fi

if command -v ufw >/dev/null 2>&1; then
    sudo ufw --force enable 2>>"$ERROR_LOG_FILE" || true
fi

ubuntu_art_file="$PROJECT_ROOT/src/assets/ubuntu.txt"
if [[ -f "$ubuntu_art_file" ]]; then
    echo
    echo "============================================================================"
    cat "$ubuntu_art_file" 2>/dev/null || true
    echo "============================================================================"
    echo
fi

echo "Setup completed. Check $ERROR_LOG_FILE for any errors."
