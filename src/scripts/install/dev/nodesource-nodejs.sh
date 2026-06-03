#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
update_apt_cache
NODE_MAJOR=24
nodesource_key="/etc/apt/keyrings/nodesource.gpg"
nodesource_list="/etc/apt/sources.list.d/nodesource.list"
install_apt_packages "ca-certificates" "curl" "gnupg"
sudo mkdir -p /etc/apt/keyrings 2>>"$ERROR_LOG_FILE" || true
if [[ ! -f "$nodesource_key" ]]; then
    curl -fsSL --connect-timeout 30 --max-time 300 https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key 2>>"$ERROR_LOG_FILE" | \
        sudo gpg --dearmor -o "$nodesource_key" 2>>"$ERROR_LOG_FILE" || log_error "Failed to install NodeSource GPG key"
fi
if [[ ! -f "$nodesource_list" ]] || ! grep -Fq "deb.nodesource.com/node_${NODE_MAJOR}.x" "$nodesource_list" 2>/dev/null; then
    echo "deb [signed-by=${nodesource_key}] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" 2>>"$ERROR_LOG_FILE" | \
        sudo tee "$nodesource_list" > /dev/null 2>>"$ERROR_LOG_FILE" || log_error "Failed to write NodeSource apt source list"
    update_apt_cache
fi
install_apt_packages "nodejs"
