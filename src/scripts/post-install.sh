#!/bin/bash

# Post-Installation Cleanup and Configuration Script
# Performs final system updates, cleanup, and displays completion information
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Main function
main() {
    # Final system update
    update_apt_cache
    sudo apt-get upgrade -y 2>>"$ERROR_LOG_FILE" || true
    sudo apt-get autoremove -y 2>>"$ERROR_LOG_FILE" || true
    sudo apt-get autoclean 2>>"$ERROR_LOG_FILE" || true

    # Configure Docker service
    if command -v docker >/dev/null 2>&1; then
        sudo systemctl enable docker.service 2>>"$ERROR_LOG_FILE" || true
        sudo systemctl start docker.service 2>>"$ERROR_LOG_FILE" || true
        sudo usermod -aG docker "$USER" 2>>"$ERROR_LOG_FILE" || true
    fi

    # Ensure UFW is enabled
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw --force enable 2>>"$ERROR_LOG_FILE" || true
    fi

    # Display completion info
    local wolf_art_file="$PROJECT_ROOT/src/assets/wolf.txt"
    if [[ -f "$wolf_art_file" ]]; then
        echo
        echo "============================================================================"
        cat "$wolf_art_file" 2>/dev/null || true
        echo "============================================================================"
        echo
    fi

    echo "Setup completed. Check $ERROR_LOG_FILE for any errors."
}

# Execute main function
main "$@"
