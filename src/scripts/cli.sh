#!/bin/bash

# CLI Tools Installation Script
# Installs essential command-line tools and package managers
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Install package managers
install_package_managers() {
    log_info "Setting up package managers..."

    # Install Flatpak if not present
    if ! is_package_installed "flatpak"; then
        log_info "Installing Flatpak package manager..."
        install_apt_packages "flatpak"

        # Add Flathub repository
        if ! flatpak remotes | grep -q "flathub"; then
            log_info "Adding Flathub repository..."
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            log_success "Added Flathub repository"
        else
            log_info "Flathub repository already configured"
        fi
    else
        log_info "Flatpak is already installed"
    fi
}

# Install CLI tools
install_cli_tools() {
    log_info "Installing essential CLI tools..."

    # Define CLI tools to install
    local cli_tools=(
        "bat"           # Better cat with syntax highlighting
        "curl"          # Data transfer tool
        "eza"           # Modern ls replacement
        "fd-find"       # Better find alternative
        "git"           # Version control system
        "htop"          # Interactive process viewer
        "jq"            # JSON processor
        "ripgrep"       # Fast text search tool
        "vim"           # Text editor
        "wget"          # Web content retrieval
    )

    # Install all CLI tools in batch
    install_apt_packages "${cli_tools[@]}"
}

# Install fastfetch with PPA
install_fastfetch() {
    log_info "Installing fastfetch system information tool..."

    if ! is_installed "fastfetch"; then
        # Add PPA repository for fastfetch
        if ! grep -q "zhangsongcui3371/fastfetch" /etc/apt/sources.list.d/*.list 2>/dev/null; then
            log_info "Adding fastfetch PPA repository..."
            sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
            update_apt_cache
        fi

        # Install fastfetch
        install_apt_packages "fastfetch"
    else
        log_info "fastfetch is already installed"
    fi
}

# Main function
main() {
    log_info "Starting CLI tools installation..."

    # Update package cache
    update_apt_cache

    # Install components
    install_package_managers
    install_cli_tools
    install_fastfetch

    log_success "CLI tools installation completed!"
}

# Execute main function
main "$@"

