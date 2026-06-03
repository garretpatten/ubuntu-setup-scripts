#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
install_apt_packages unattended-upgrades
auto_upgrades="/etc/apt/apt.conf.d/20auto-upgrades"
if [[ ! -f "$auto_upgrades" ]]; then
    {
        echo 'APT::Periodic::Update-Package-Lists "1";'
        echo 'APT::Periodic::Download-Upgradeable-Packages "0";'
        echo 'APT::Periodic::AutocleanInterval "0";'
        echo 'APT::Periodic::Unattended-Upgrade "1";'
    } | sudo tee "$auto_upgrades" >/dev/null 2>>"$ERROR_LOG_FILE" || true
fi
