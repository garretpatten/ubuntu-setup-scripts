#!/bin/bash

# Media Applications Installation Script
# Installs browsers, media players, and streaming applications
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Install web browsers
install_browsers() {
    log_info "Installing web browsers..."

    # Install Brave browser
    install_brave_browser() {
        if ! is_installed "brave-browser"; then
            log_info "Installing Brave browser..."

            # Add Brave's GPG key
            if [[ ! -f "/usr/share/keyrings/brave-browser-archive-keyring.gpg" ]]; then
                log_info "Adding Brave browser GPG key..."
                curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | \
                    sudo gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg
            fi

            # Add Brave repository
            if ! grep -q "brave-browser-apt-release" /etc/apt/sources.list.d/*.list 2>/dev/null; then
                log_info "Adding Brave browser repository..."
                echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
                    sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
                update_apt_cache
            fi

            # Install Brave browser
            install_apt_packages "brave-browser"
        else
            log_info "Brave browser is already installed"
        fi
    }

    install_brave_browser
}

# Install media players and streaming applications
install_media_applications() {
    log_info "Installing media applications..."

    # Define media applications to install
    local media_apps=(
        "vlc"               # VLC media player
        "spotify-client"    # Spotify music streaming (if available in repos)
    )

    # Install VLC media player
    if ! is_package_installed "vlc"; then
        log_info "Installing VLC media player..."
        install_apt_packages "vlc"
    else
        log_info "VLC media player is already installed"
    fi

    # Install Spotify via snap (more reliable than apt)
    install_spotify() {
        if ! is_installed "spotify"; then
            log_info "Installing Spotify..."

            # Check if snap is available
            if is_installed "snap"; then
                sudo snap install spotify
                log_success "Spotify installed via snap"
            else
                # Fallback to apt if available
                if is_package_installed "spotify-client"; then
                    log_info "Spotify is already installed via apt"
                else
                    log_warning "Neither snap nor apt package available for Spotify"
                    log_info "You may need to install Spotify manually from https://spotify.com"
                fi
            fi
        else
            log_info "Spotify is already installed"
        fi
    }

    install_spotify
}

# Install additional multimedia codecs and tools
install_multimedia_codecs() {
    log_info "Installing multimedia codecs and tools..."

    # Define multimedia packages
    local multimedia_packages=(
        "ubuntu-restricted-extras"  # Codecs for proprietary formats
        "ffmpeg"                    # Video/audio processing tool
        "gstreamer1.0-plugins-bad"  # Additional GStreamer plugins
        "gstreamer1.0-plugins-ugly" # More GStreamer plugins
        "gstreamer1.0-libav"        # GStreamer libav plugin
    )

    # Install multimedia packages
    # Note: ubuntu-restricted-extras requires user interaction, so handle separately
    log_info "Installing essential multimedia codecs..."

    # Install non-interactive packages first
    local non_interactive_packages=(
        "ffmpeg"
        "gstreamer1.0-plugins-bad"
        "gstreamer1.0-plugins-ugly"
        "gstreamer1.0-libav"
    )
    install_apt_packages "${non_interactive_packages[@]}"

    # Install ubuntu-restricted-extras with automatic yes responses
    if ! is_package_installed "ubuntu-restricted-extras"; then
        log_info "Installing ubuntu-restricted-extras (this may take a while)..."
        # Pre-accept EULA for ttf-mscorefonts-installer
        echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | \
            sudo debconf-set-selections

        # Install with non-interactive frontend
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-restricted-extras || \
            log_warning "Failed to install ubuntu-restricted-extras"
    else
        log_info "ubuntu-restricted-extras is already installed"
    fi
}

# Main function
main() {
    log_info "Starting media applications installation..."

    # Update package cache
    update_apt_cache

    # Install components
    install_browsers
    install_media_applications
    install_multimedia_codecs

    log_success "Media applications installation completed!"
    log_info "You may need to restart your browser to use new codecs"
}

# Execute main function
main "$@"

