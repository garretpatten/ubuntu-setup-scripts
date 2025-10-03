#!/bin/bash

# Post-Installation Cleanup and Configuration Script
# Performs final system updates, cleanup, and displays completion information
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Perform final system update and cleanup
perform_final_system_update() {
    log_info "Performing final system update and cleanup..."

    # Update package lists
    update_apt_cache

    # Upgrade any packages that may have been added
    log_info "Upgrading any newly available packages..."
    sudo apt-get upgrade -y || log_warning "Some packages failed to upgrade"

    # Remove unnecessary packages and dependencies
    log_info "Removing unnecessary packages and dependencies..."
    sudo apt-get autoremove -y || log_warning "Failed to remove some unnecessary packages"

    # Clean package cache to free up space
    log_info "Cleaning package cache..."
    sudo apt-get autoclean || log_warning "Failed to clean package cache"

    log_success "Final system update and cleanup completed"
}

# Configure system services
configure_system_services() {
    log_info "Configuring system services..."

    # Enable and start Docker service if installed
    configure_docker_service() {
        if is_installed "docker"; then
            log_info "Configuring Docker service..."

            # Enable Docker service to start on boot
            sudo systemctl enable docker.service || log_warning "Failed to enable Docker service"

            # Start Docker service
            sudo systemctl start docker.service || log_warning "Failed to start Docker service"

            # Add current user to docker group
            if ! groups "$USER" | grep -q docker; then
                log_info "Adding user $USER to docker group..."
                sudo usermod -aG docker "$USER"
                log_success "User added to docker group"
                log_info "You'll need to log out and back in for Docker group changes to take effect"
            else
                log_info "User $USER is already in docker group"
            fi
        fi
    }

    # Configure firewall if installed
    configure_firewall_service() {
        if is_installed "ufw"; then
            log_info "Ensuring UFW firewall is properly configured..."
            sudo ufw --force enable || log_warning "Failed to enable UFW firewall"
        fi
    }

    configure_docker_service
    configure_firewall_service
}

# Display system information and completion message
display_completion_info() {
    log_info "Displaying system setup completion information..."

    # Display ASCII art if available
    display_ascii_art() {
        local wolf_art_file="$PROJECT_ROOT/src/assets/wolf.txt"
        if [[ -f "$wolf_art_file" ]]; then
            echo
            echo "============================================================================"
            echo
            cat "$wolf_art_file" 2>/dev/null || log_warning "Could not display ASCII art"
            echo
            echo "============================================================================"
            echo
        fi
    }

    # Display post-installation instructions
    display_instructions() {
        echo
        echo "============================================================================"
        echo "                        SETUP COMPLETION INSTRUCTIONS"
        echo "============================================================================"
        echo

        # Docker instructions
        if is_installed "docker"; then
            echo "🐳 Docker Configuration:"
            echo "   The following commands have been run automatically:"
            echo "   • sudo systemctl enable docker.service"
            echo "   • sudo systemctl start docker.service"
            echo "   • sudo usermod -aG docker $USER"
            echo
            echo "   To use Docker without sudo, log out and log back in."
            echo
        fi

        # Shell change instructions
        if is_installed "zsh"; then
            echo "🐚 Shell Configuration:"
            echo "   Your default shell has been changed to Zsh."
            echo "   Log out and log back in to use the new shell."
            echo
        fi

        # Security recommendations
        echo "🔒 Security Recommendations:"
        echo "   • UFW firewall has been enabled"
        echo "   • Review and configure your VPN settings"
        echo "   • Set up 1Password and import your passwords"
        echo "   • Configure Signal Messenger"
        echo

        # Development environment
        echo "💻 Development Environment:"
        echo "   • Your home directory has been organized"
        echo "   • Development tools have been installed"
        echo "   • Git has been configured with your information"
        echo

        # Next steps
        echo "📋 Next Steps:"
        echo "   1. Log out and log back in to apply all changes"
        echo "   2. Open a new terminal to test your shell configuration"
        echo "   3. Configure your development tools and IDE preferences"
        echo "   4. Set up your VPN and security applications"
        echo "   5. Review the error log if any issues occurred: $ERROR_LOG_FILE"
        echo
    }

    display_ascii_art
    display_instructions

    echo "============================================================================"
    echo
    log_success "🎉 Ubuntu system setup is now complete!"
    echo
    echo "============================================================================"
}

# Generate setup summary report
generate_setup_summary() {
    log_info "Generating setup summary report..."

    local summary_file="$PROJECT_ROOT/setup_summary.txt"

    {
        echo "Ubuntu Setup Summary Report"
        echo "Generated on: $(date)"
        echo "User: $USER"
        echo "System: $(lsb_release -d | cut -f2)"
        echo "Architecture: $(dpkg --print-architecture)"
        echo
        echo "Installed Applications:"
        echo "======================"

        # Check for installed applications
        local apps_to_check=(
            "git" "curl" "wget" "vim" "zsh" "tmux" "alacritty"
            "docker" "node" "python3" "gh" "code" "brave-browser"
            "vlc" "signal-desktop" "1password" "flatpak"
        )

        for app in "${apps_to_check[@]}"; do
            if is_installed "$app"; then
                echo "✓ $app"
            else
                echo "✗ $app (not installed)"
            fi
        done

        echo
        echo "Setup completed at: $(date)"

    } > "$summary_file"

    log_success "Setup summary saved to: $summary_file"
}

# Main function
main() {
    log_info "Starting post-installation cleanup and configuration..."

    # Perform final tasks
    perform_final_system_update
    configure_system_services
    generate_setup_summary
    display_completion_info

    log_success "Post-installation setup completed successfully!"
}

# Execute main function
main "$@"

