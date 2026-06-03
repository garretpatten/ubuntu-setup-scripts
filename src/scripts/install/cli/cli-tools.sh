#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
cli_tools=(
    "bat" "curl" "eza" "fd-find" "git" "htop" "jq" "ripgrep" "vim" "wget"
)
install_apt_packages "${cli_tools[@]}"
