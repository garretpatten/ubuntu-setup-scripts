#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
update_apt_cache
install_apt_packages "ufw" "openvpn"
