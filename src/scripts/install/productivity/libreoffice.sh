#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
update_apt_cache
libreoffice_packages=("libreoffice" "libreoffice-gtk3" "libreoffice-style-breeze")
install_apt_packages "${libreoffice_packages[@]}"
