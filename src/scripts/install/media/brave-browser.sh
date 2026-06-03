#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
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
