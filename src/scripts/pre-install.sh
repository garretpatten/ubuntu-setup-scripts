#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

sudo apt-get upgrade -y 2>>"$ERROR_LOG_FILE" || true
sudo apt-get autoremove -y 2>>"$ERROR_LOG_FILE" || true
sudo apt-get autoclean 2>>"$ERROR_LOG_FILE" || true

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

if [[ "$(timedatectl show --property=Timezone --value)" == "UTC" ]]; then
    sudo timedatectl set-timezone America/New_York 2>>"$ERROR_LOG_FILE" || true
fi
