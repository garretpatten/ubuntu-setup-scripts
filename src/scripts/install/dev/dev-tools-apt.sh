#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
dev_tools=("gh" "shellcheck" "git")
install_apt_packages "${dev_tools[@]}"
