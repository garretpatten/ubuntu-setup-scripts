#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
sudo add-apt-repository -y ppa:neovim-ppa/stable 2>>"$ERROR_LOG_FILE" || true
update_apt_cache
neovim_packages=("neovim" "python3-neovim" "python3-dev" "python3-pip")
install_apt_packages "${neovim_packages[@]}"
