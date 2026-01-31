#!/bin/bash

# Home Directory Organization Script
# Removes unused default directories and creates useful project directories
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Main function
main() {
    # Remove unused directories (only if empty)
    remove_empty_directory "$HOME/Music"
    remove_empty_directory "$HOME/Public"
    remove_empty_directory "$HOME/Templates"

    # Create project directories
    ensure_directory "$HOME/AppImages"
    ensure_directory "$HOME/Hacking"
    ensure_directory "$HOME/Projects"
    ensure_directory "$HOME/Scripts"
    ensure_directory "$HOME/Tools"

    # Create subdirectories
    ensure_directory "$HOME/Projects/personal"
    ensure_directory "$HOME/Projects/work"
    ensure_directory "$HOME/Projects/learning"
    ensure_directory "$HOME/Projects/opensource"
    ensure_directory "$HOME/Scripts/automation"
    ensure_directory "$HOME/Scripts/utilities"
    ensure_directory "$HOME/Scripts/backup"

    # Create symlinks
    if [[ -d "$HOME/Desktop" ]]; then
        ln -sf "$HOME/Projects" "$HOME/Desktop/Projects" 2>/dev/null || true
    fi
    ln -sf "$HOME/Downloads" "$HOME/Projects/downloads" 2>/dev/null || true

    # Set permissions
    chmod 755 "$HOME/Scripts" 2>/dev/null || true
    chmod 700 "$HOME/Hacking" 2>/dev/null || true
}

# Execute main function
main "$@"
