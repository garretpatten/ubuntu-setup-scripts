#!/bin/bash

# Security Tools Installation Script
# Installs authentication, defense, and offensive security tools
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Install authentication tools
install_authentication_tools() {
    log_info "Installing authentication tools..."

    # Install 1Password desktop app and CLI
    install_1password() {
        if ! is_installed "1password"; then
            log_info "Installing 1Password desktop app and CLI..."

            # Download and install 1Password desktop app
            local onepassword_tarball="$TEMP_DIR/1password-latest.tar.gz"
            download_file_safe "https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz" "$onepassword_tarball"

            # Extract and install
            cd "$TEMP_DIR" || return 1
            tar -xf "$onepassword_tarball"
            sudo mkdir -p /opt/1Password
            sudo mv 1password-*/* /opt/1Password/
            sudo /opt/1Password/after-install.sh

            # Install 1Password CLI via repository
            if [[ ! -f "/usr/share/keyrings/1password-archive-keyring.gpg" ]]; then
                log_info "Adding 1Password repository..."
                curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
                    sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
                    sudo tee /etc/apt/sources.list.d/1password.list > /dev/null

                # Set up package signing
                sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
                curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
                    sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol > /dev/null

                sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
                curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
                    sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

                update_apt_cache
            fi

            # Install 1Password CLI
            install_apt_packages "1password-cli"
            log_success "1Password installed successfully"
        else
            log_info "1Password is already installed"
        fi
    }

    install_1password
}

# Install defense tools
install_defense_tools() {
    log_info "Installing defense and security tools..."

    # Define defense tools to install
    local defense_tools=(
        "clamav"        # Antivirus scanner
        "clamav-daemon" # ClamAV daemon
        "ufw"           # Uncomplicated Firewall
        "openvpn"       # OpenVPN client
        "gnome-shell"   # Required for some VPN integrations
    )

    # Install defense tools in batch
    install_apt_packages "${defense_tools[@]}"

    # Configure and enable firewall
    configure_firewall() {
        log_info "Configuring UFW firewall..."

        # Enable UFW with default policies
        sudo ufw --force reset
        sudo ufw default deny incoming
        sudo ufw default allow outgoing

        # Allow SSH (if needed)
        sudo ufw allow ssh

        # Enable firewall
        sudo ufw --force enable
        log_success "UFW firewall configured and enabled"
    }

    # Update ClamAV virus definitions
    update_clamav() {
        if is_installed "freshclam"; then
            log_info "Updating ClamAV virus definitions..."
            sudo freshclam || log_warning "Failed to update ClamAV definitions"
        fi
    }

    configure_firewall
    update_clamav
}

# Install ProtonVPN
install_protonvpn() {
    if ! is_installed "protonvpn-app"; then
        log_info "Installing ProtonVPN..."

        # Download ProtonVPN repository package
        local protonvpn_deb="$TEMP_DIR/protonvpn-stable-release.deb"
        local expected_hash="0b14e71586b22e498eb20926c48c7b434b751149b1f2af9902ef1cfe6b03e180"

        download_file_safe "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb" \
            "$protonvpn_deb" "$expected_hash"

        # Install repository package
        sudo dpkg -i "$protonvpn_deb"
        update_apt_cache

        # Install ProtonVPN packages
        local protonvpn_packages=(
            "proton-vpn-gnome-desktop"
            "libayatana-appindicator3-1"
            "gir1.2-ayatanaappindicator3-0.1"
            "gnome-shell-extension-appindicator"
        )
        install_apt_packages "${protonvpn_packages[@]}"

        log_success "ProtonVPN installed successfully"
    else
        log_info "ProtonVPN is already installed"
    fi
}

# Install Signal Messenger
install_signal() {
    if ! is_installed "signal-desktop"; then
        log_info "Installing Signal Messenger..."

        # Add Signal's GPG key with proper error handling
        if [[ ! -f "/usr/share/keyrings/signal-desktop-keyring.gpg" ]]; then
            log_info "Adding Signal GPG key..."

            # Download and verify the GPG key
            local temp_key_file="$TEMP_DIR/signal-key.asc"
            if wget -O "$temp_key_file" https://updates.signal.org/desktop/apt/keys.asc; then
                # Import the key
                if gpg --dearmor < "$temp_key_file" | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null; then
                    log_success "Signal GPG key added successfully"
                else
                    log_error "Failed to import Signal GPG key"
                    return 1
                fi
            else
                log_error "Failed to download Signal GPG key"
                return 1
            fi
        else
            log_info "Signal GPG key already exists"
        fi

        # Add Signal repository
        local signal_list_file="/etc/apt/sources.list.d/signal-xenial.list"
        if [[ ! -f "$signal_list_file" ]] || ! grep -q "updates.signal.org" "$signal_list_file" 2>/dev/null; then
            log_info "Adding Signal repository..."
            echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | \
                sudo tee "$signal_list_file" > /dev/null

            # Update apt cache after adding repository
            log_info "Updating package lists for Signal repository..."
            if ! sudo apt-get update -y; then
                log_error "Failed to update package lists after adding Signal repository"
                return 1
            fi
        else
            log_info "Signal repository already configured"
        fi

        # Install Signal
        install_apt_packages "signal-desktop"
    else
        log_info "Signal Messenger is already installed"
    fi
}

# Install offensive security tools
install_offensive_security_tools() {
    log_info "Installing offensive security tools..."

    # Define APT security tools
    local apt_security_tools=(
        "nmap"          # Network mapper
        "exiftool"      # EXIF metadata tool
    )

    # Install APT security tools in batch
    install_apt_packages "${apt_security_tools[@]}"

    # Install OWASP ZAP via Snap (not available in apt)
    install_zaproxy_snap() {
        if ! is_installed "zaproxy"; then
            log_info "Installing OWASP ZAP via Snap..."

            # Ensure snapd is installed
            if ! is_installed "snap"; then
                log_info "Installing snapd..."
                install_apt_packages "snapd"
            fi

            # Install OWASP ZAP
            if sudo snap install zaproxy --classic; then
                log_success "OWASP ZAP installed successfully"
            else
                log_error "Failed to install OWASP ZAP via Snap"
                return 1
            fi
        else
            log_info "OWASP ZAP is already installed"
        fi
    }

    # Install OWASP ZAP
    install_zaproxy_snap

    # Create hacking directory structure
    setup_hacking_directories() {
        local hacking_dir="$HOME/Hacking"
        ensure_directory "$hacking_dir"

        # Clone security repositories
        local repos=(
            "https://github.com/swisskyrepo/PayloadsAllTheThings:PayloadsAllTheThings"
            "https://github.com/danielmiessler/SecLists:SecLists"
        )

        for repo_info in "${repos[@]}"; do
            local repo_url="${repo_info%:*}"
            local repo_name="${repo_info#*:}"
            local repo_path="$hacking_dir/$repo_name"

            if [[ ! -d "$repo_path" ]]; then
                log_info "Cloning $repo_name repository..."
                clone_repository_safe "$repo_url" "$repo_path"
            else
                log_info "$repo_name repository already exists"
            fi
        done
    }

    setup_hacking_directories
}

# Install additional security tools (placeholder for future expansion)
install_additional_security_tools() {
    log_info "Setting up additional security tools..."

    # Burp Suite Community Edition (manual installation required)
    log_info "Note: Burp Suite Community Edition requires manual installation"
    log_info "Download from: https://portswigger.net/burp/communitydownload"

    # Create desktop shortcuts directory
    ensure_directory "$HOME/.local/share/applications"
}

# Main function
main() {
    log_info "Starting security tools installation..."

    # Update package cache
    update_apt_cache

    # Install components
    install_authentication_tools
    install_defense_tools
    install_protonvpn
    install_signal
    install_offensive_security_tools
    install_additional_security_tools

    log_success "Security tools installation completed!"
    log_info "Remember to configure your VPN and security tools after installation"
    log_info "UFW firewall has been enabled with default deny incoming policy"
}

# Execute main function
main "$@"

