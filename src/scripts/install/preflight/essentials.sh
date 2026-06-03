#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
essential_tools=(
    "git" "curl" "wget" "software-properties-common"
    "apt-transport-https" "ca-certificates" "gnupg" "lsb-release"
)
install_apt_packages "${essential_tools[@]}"
