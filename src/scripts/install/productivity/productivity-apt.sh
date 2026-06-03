#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
productivity_packages=("keepassxc" "redshift" "flameshot")
install_apt_packages "${productivity_packages[@]}"
