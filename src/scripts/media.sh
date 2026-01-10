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

    # Install Spotify with multiple fallback methods
    install_spotify() {
        if ! is_installed "spotify"; then
            log_info "Installing Spotify..."

            # Try snap first (Ubuntu)
            if is_snap_available; then
                if sudo snap install spotify; then
                    log_success "Spotify installed via snap"
                    return 0
                else
                    log_warning "Snap installation failed, trying alternative methods..."
                fi
            fi

            # Try Flatpak (works on both Ubuntu and Mint)
            if is_flatpak_available; then
                if flatpak install -y flathub com.spotify.Client; then
                    log_success "Spotify installed via Flatpak"
                    return 0
                else
                    log_warning "Flatpak installation failed, trying apt..."
                fi
            fi

            # Try apt as fallback
            if apt-cache show spotify-client >/dev/null 2>&1; then
                if install_apt_packages "spotify-client"; then
                    log_success "Spotify installed via apt"
                    return 0
                else
                    log_warning "Apt installation failed"
                fi
            fi

            log_warning "No suitable installation method available for Spotify"
            log_info "You may need to install Spotify manually from https://spotify.com"
        else
            log_info "Spotify is already installed"
        fi
    }

    install_spotify
}

# Install additional multimedia codecs and tools
install_multimedia_codecs() {
    log_info "Installing multimedia codecs and tools..."

    # Install distribution-agnostic multimedia packages first
    local multimedia_packages=(
        "ffmpeg"                    # Video/audio processing tool
        "gstreamer1.0-plugins-bad"  # Additional GStreamer plugins
        "gstreamer1.0-plugins-ugly" # More GStreamer plugins
        "gstreamer1.0-libav"        # GStreamer libav plugin
        "gstreamer1.0-plugins-good" # GStreamer good plugins
    )

    log_info "Installing essential multimedia codecs..."
    install_apt_packages "${multimedia_packages[@]}"

    # Install distribution-specific restricted extras
    install_restricted_extras() {
        local distro_id
        distro_id=$(lsb_release -si 2>/dev/null || echo "Unknown")

        case "$distro_id" in
            "Ubuntu")
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
                ;;
            "LinuxMint")
                # Linux Mint has its own multimedia codecs package
                if ! is_package_installed "mint-meta-codecs"; then
                    log_info "Installing Linux Mint multimedia codecs..."
                    install_apt_packages "mint-meta-codecs" || \
                        log_warning "Failed to install mint-meta-codecs"
                else
                    log_info "Linux Mint multimedia codecs already installed"
                fi
                ;;
            *)
                log_info "Distribution-specific codecs not available for $distro_id"
                log_info "Basic codecs have been installed"
                ;;
        esac
    }

    install_restricted_extras
}

# Main function
main() {
    log_info "Starting media applications installation..."

    # Update package cache
    update_apt_cache

    # Install components with error handling
    execute_with_fallback install_browsers
    execute_with_fallback install_media_applications
    execute_with_fallback install_multimedia_codecs

    log_success "Media applications installation completed!"
    log_info "You may need to restart your browser to use new codecs"
    log_info "Check $ERROR_LOG_FILE for any failed installations"
}

# Execute main function
main "$@"

