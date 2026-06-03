#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
install_apt_packages "zsh-autosuggestions" "zsh-syntax-highlighting"
