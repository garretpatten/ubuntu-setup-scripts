#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch 2>>"$ERROR_LOG_FILE" || true
update_apt_cache
install_apt_packages "fastfetch"
