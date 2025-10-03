#!/bin/bash

# Productivity Applications Installation Script
# Installs productivity tools, office applications, and utilities
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Install office and document applications
install_office_applications() {
    log_info "Installing office and document applications..."

    # Install LibreOffice suite
    install_libreoffice() {
        local libreoffice_packages=(
            "libreoffice"           # Complete office suite
            "libreoffice-gtk3"      # GTK3 integration
            "libreoffice-style-breeze" # Modern theme
        )

        log_info "Installing LibreOffice office suite..."
        install_apt_packages "${libreoffice_packages[@]}"
    }

    # Install document viewers and editors
    install_document_tools() {
        local document_packages=(
            "evince"                # PDF viewer
            "okular"                # Advanced document viewer
            "pandoc"                # Document converter
            "texlive-latex-base"    # LaTeX support
            "ghostscript"           # PostScript/PDF interpreter
        )

        log_info "Installing document tools..."
        install_apt_packages "${document_packages[@]}"
    }

    install_libreoffice
    install_document_tools
}

# Install communication and collaboration tools
install_communication_tools() {
    log_info "Installing communication and collaboration tools..."

    # Install Zoom via snap (more reliable than manual installation)
    install_zoom() {
        if ! is_installed "zoom"; then
            log_info "Installing Zoom video conferencing..."
            if is_installed "snap"; then
                sudo snap install zoom-client
                log_success "Zoom installed via snap"
            else
                log_warning "Snap not available, skipping Zoom installation"
                log_info "You can install Zoom manually from https://zoom.us/download"
            fi
        else
            log_info "Zoom is already installed"
        fi
    }

    # Install Discord via snap
    install_discord() {
        if ! is_installed "discord"; then
            log_info "Installing Discord communication platform..."
            if is_installed "snap"; then
                sudo snap install discord
                log_success "Discord installed via snap"
            else
                log_warning "Snap not available, skipping Discord installation"
            fi
        else
            log_info "Discord is already installed"
        fi
    }

    # Install Slack via snap
    install_slack() {
        if ! is_installed "slack"; then
            log_info "Installing Slack team communication..."
            if is_installed "snap"; then
                sudo snap install slack --classic
                log_success "Slack installed via snap"
            else
                log_warning "Snap not available, skipping Slack installation"
            fi
        else
            log_info "Slack is already installed"
        fi
    }

    install_zoom
    install_discord
    install_slack
}

# Install productivity and note-taking applications
install_productivity_tools() {
    log_info "Installing productivity and note-taking tools..."

    # Install Notion via APT (community repackaged version)
    install_notion() {
        if ! is_installed "notion-app"; then
            log_info "Installing Notion note-taking app (community repackaged)..."

            # Add Notion repackaged repository
            if ! grep -q "apt.fury.io/notion-repackaged" /etc/apt/sources.list.d/*.list 2>/dev/null; then
                log_info "Adding Notion repackaged repository..."
                echo "deb [trusted=yes] https://apt.fury.io/notion-repackaged/ /" | \
                    sudo tee /etc/apt/sources.list.d/notion-repackaged.list > /dev/null

                # Update package lists
                sudo apt-get update -y || {
                    log_warning "Failed to update package lists after adding Notion repository"
                }
            fi

            # Install Notion
            if sudo apt-get install -y notion-app; then
                log_success "Notion installed successfully"
            else
                log_warning "Failed to install Notion. You can access Notion via web browser at https://notion.so"
            fi
        else
            log_info "Notion is already installed"
        fi
    }

    # Install Obsidian via Flatpak
    install_obsidian() {
        if ! is_flatpak_installed "md.obsidian.Obsidian"; then
            log_info "Installing Obsidian knowledge management..."
            flatpak install -y flathub md.obsidian.Obsidian || \
                log_warning "Failed to install Obsidian via Flatpak"
        else
            log_info "Obsidian is already installed"
        fi
    }

    # Install standard productivity tools
    install_standard_productivity() {
        local productivity_packages=(
            "thunderbird"           # Email client
            "firefox"               # Web browser (backup)
            "keepassxc"             # Password manager (backup)
            "redshift"              # Blue light filter
            "flameshot"             # Screenshot tool
            "tree"                  # Directory tree viewer
            "ncdu"                  # Disk usage analyzer
        )

        log_info "Installing standard productivity tools..."
        install_apt_packages "${productivity_packages[@]}"
    }

    install_notion
    install_obsidian
    install_standard_productivity
}

# Install system utilities and tools
install_system_utilities() {
    log_info "Installing system utilities..."

    # Install Balena Etcher via AppImage (more reliable than Flatpak)
    install_balena_etcher() {
        local etcher_dir="$HOME/.local/bin"
        local etcher_path="$etcher_dir/balenaEtcher.AppImage"

        if [[ ! -f "$etcher_path" ]]; then
            log_info "Installing Balena Etcher USB imaging tool via AppImage..."

            # Ensure directory exists
            ensure_directory "$etcher_dir"

            # Install libfuse2 dependency for AppImages
            if ! is_package_installed "libfuse2"; then
                log_info "Installing libfuse2 for AppImage support..."
                install_apt_packages "libfuse2"
            fi

            # Download latest Balena Etcher AppImage
            local download_url="https://github.com/balena-io/etcher/releases/latest/download/balenaEtcher-1.18.11-x64.AppImage"

            if download_file_safe "$download_url" "$etcher_path"; then
                # Make executable
                chmod +x "$etcher_path"

                # Create desktop entry
                local desktop_file="$HOME/.local/share/applications/balena-etcher.desktop"
                ensure_directory "$(dirname "$desktop_file")"

                cat > "$desktop_file" << EOF
[Desktop Entry]
Name=balenaEtcher
Comment=Flash OS images to SD cards and USB drives
Exec=$etcher_path
Icon=balena-etcher
Type=Application
Categories=System;Utility;
EOF

                log_success "Balena Etcher installed successfully"
            else
                log_warning "Failed to download Balena Etcher AppImage"
            fi
        else
            log_info "Balena Etcher is already installed"
        fi
    }

    # Install system monitoring tools
    install_monitoring_tools() {
        local monitoring_packages=(
            "htop"                  # Interactive process viewer
            "iotop"                 # I/O monitoring
            "nethogs"               # Network bandwidth monitor
            "dstat"                 # System resource statistics
            "lm-sensors"            # Hardware monitoring
        )

        log_info "Installing system monitoring tools..."
        install_apt_packages "${monitoring_packages[@]}"
    }

    # Install file management tools
    install_file_tools() {
        local file_packages=(
            "ranger"                # Terminal file manager
            "mc"                    # Midnight Commander
            "p7zip-full"            # 7-Zip archive support
            "unrar"                 # RAR archive support
            "zip"                   # ZIP archive creation
            "unzip"                 # ZIP archive extraction
        )

        log_info "Installing file management tools..."
        install_apt_packages "${file_packages[@]}"
    }

    install_balena_etcher
    install_monitoring_tools
    install_file_tools
}

# Configure productivity applications
configure_productivity_apps() {
    log_info "Configuring productivity applications..."

    # Configure Redshift (blue light filter)
    configure_redshift() {
        local redshift_config="$HOME/.config/redshift.conf"
        if [[ ! -f "$redshift_config" ]] && is_installed "redshift"; then
            log_info "Configuring Redshift blue light filter..."
            ensure_directory "$HOME/.config"

            cat > "$redshift_config" << 'EOF'
[redshift]
temp-day=6500
temp-night=4500
fade=1
gamma=0.8
location-provider=manual
adjustment-method=randr

[manual]
lat=40.7
lon=-74.0
EOF
            log_success "Redshift configured"
        fi
    }

    # Configure Flameshot (screenshot tool)
    configure_flameshot() {
        if is_installed "flameshot"; then
            log_info "Flameshot screenshot tool is installed"
            log_info "Use 'flameshot gui' to take screenshots"
        fi
    }

    configure_redshift
    configure_flameshot
}

# Main function
main() {
    log_info "Starting productivity applications installation..."

    # Update package cache
    update_apt_cache

    # Install productivity components
    install_office_applications
    install_communication_tools
    install_productivity_tools
    install_system_utilities
    configure_productivity_apps

    log_success "Productivity applications installation completed!"
    log_info "Note: Some applications may require additional configuration"
}

# Execute main function
main "$@"

