#!/bin/bash

# Pre-Installation Setup Script
# Performs initial system updates and installs essential tools
# Author: Garret Patten

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Update and upgrade system
update_apt_cache
sudo apt-get upgrade -y 2>>"$ERROR_LOG_FILE" || true
sudo apt-get autoremove -y 2>>"$ERROR_LOG_FILE" || true
sudo apt-get autoclean 2>>"$ERROR_LOG_FILE" || true

# Install essential tools
local essential_tools=(
    "git"
    "curl"
    "wget"
    "software-properties-common"
    "apt-transport-https"
    "ca-certificates"
    "gnupg"
    "lsb-release"
)
install_apt_packages "${essential_tools[@]}"

# Configure automatic updates
if [[ ! -f "/etc/apt/apt.conf.d/20auto-upgrades" ]]; then
    sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF
fi

# Set timezone if UTC
if [[ "$(timedatectl show --property=Timezone --value)" == "UTC" ]]; then
    sudo timedatectl set-timezone America/New_York 2>>"$ERROR_LOG_FILE" || true
fi
