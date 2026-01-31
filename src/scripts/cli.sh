#!/bin/bash

# CLI Tools Installation Script
# Installs essential command-line tools and package managers
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Main function
main() {
    # Update package cache
    update_apt_cache

    # Install Flatpak
    install_apt_packages "flatpak"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>>"$ERROR_LOG_FILE" || true

    # Install CLI tools
    local cli_tools=(
        "bat"
        "curl"
        "eza"
        "fd-find"
        "git"
        "htop"
        "jq"
        "ripgrep"
        "vim"
        "wget"
    )
    install_apt_packages "${cli_tools[@]}"

    # Install fastfetch
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch 2>>"$ERROR_LOG_FILE" || true
    update_apt_cache
    install_apt_packages "fastfetch"
}

# Execute main function
main "$@"
