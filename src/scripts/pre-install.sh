#!/bin/bash

# Pre-Installation Setup Script
# Performs initial system updates and installs essential tools
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Perform initial system update and cleanup
perform_system_update() {
    log_info "Performing initial system update and cleanup..."

    # Update package lists
    log_info "Updating package lists..."
    sudo apt-get update -y || {
        log_error "Failed to update package lists"
        return 1
    }

    # Upgrade installed packages
    log_info "Upgrading installed packages (this may take a while)..."
    sudo apt-get upgrade -y || {
        log_error "Failed to upgrade packages"
        return 1
    }

    # Remove unnecessary packages
    log_info "Removing unnecessary packages..."
    sudo apt-get autoremove -y || {
        log_warning "Failed to remove some unnecessary packages"
    }

    # Clean package cache
    log_info "Cleaning package cache..."
    sudo apt-get autoclean || {
        log_warning "Failed to clean package cache"
    }

    log_success "System update and cleanup completed"
}

# Install essential system tools
install_essential_tools() {
    log_info "Installing essential system tools..."

    # Define essential tools that should be available early
    local essential_tools=(
        "git"               # Version control system
        "curl"              # Data transfer tool
        "wget"              # Web content retrieval
        "software-properties-common"  # For managing repositories
        "apt-transport-https"         # For HTTPS repositories
        "ca-certificates"             # Certificate authorities
        "gnupg"             # GNU Privacy Guard
        "lsb-release"       # Linux Standard Base information
    )

    # Install essential tools in batch
    install_apt_packages "${essential_tools[@]}"
}

# Configure system settings for better performance
configure_system_settings() {
    log_info "Configuring system settings..."

    # Enable automatic security updates (optional)
    configure_automatic_updates() {
        if [[ ! -f "/etc/apt/apt.conf.d/20auto-upgrades" ]]; then
            log_info "Configuring automatic security updates..."
            sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF
            log_success "Automatic security updates configured"
        else
            log_info "Automatic updates already configured"
        fi
    }

    # Set timezone if not already set
    configure_timezone() {
        local current_timezone
        current_timezone="$(timedatectl show --property=Timezone --value)"

        if [[ "$current_timezone" == "UTC" ]]; then
            log_info "Setting timezone to America/New_York (change if needed)..."
            sudo timedatectl set-timezone America/New_York || \
                log_warning "Failed to set timezone"
        else
            log_info "Timezone is already set to: $current_timezone"
        fi
    }

    configure_automatic_updates
    configure_timezone
}

# Check system requirements and compatibility
check_system_requirements() {
    log_info "Checking system requirements..."

    # Check Ubuntu version
    local ubuntu_version
    ubuntu_version="$(lsb_release -rs 2>/dev/null || echo "unknown")"
    log_info "Ubuntu version: $ubuntu_version"

    # Check architecture
    local architecture
    architecture="$(dpkg --print-architecture)"
    log_info "System architecture: $architecture"

    # Check available disk space
    local available_space
    available_space="$(df -h / | awk 'NR==2 {print $4}')"
    log_info "Available disk space: $available_space"

    # Check memory
    local total_memory
    total_memory="$(free -h | awk 'NR==2 {print $2}')"
    log_info "Total memory: $total_memory"

    # Warn if running on unsupported architecture
    if [[ "$architecture" != "amd64" ]]; then
        log_warning "Some packages may not be available for architecture: $architecture"
    fi
}

# Main function
main() {
    log_info "Starting pre-installation setup..."

    # Check system requirements
    check_system_requirements

    # Perform system updates and configuration
    perform_system_update
    install_essential_tools
    configure_system_settings

    log_success "Pre-installation setup completed!"
    log_info "System is ready for application installation"
}

# Execute main function
main "$@"

