#!/bin/bash

# Ubuntu Setup Master Script
# This script orchestrates the complete Ubuntu system setup process
# Author: Garret Patten
# Usage: ./master.sh

# Source utility functions and set up environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Main setup function
main() {
    log_info "Starting Ubuntu system setup..."
    log_info "Project root: $PROJECT_ROOT"
    log_info "Script directory: $SCRIPT_DIR"

    # Detect distribution for compatibility
    detect_distribution

    # Array of setup scripts to execute in order
    local setup_scripts=(
        "pre-install.sh"
        "organizeHome.sh"
        "cli.sh"
        "dev.sh"
        "media.sh"
        "productivity.sh"
        "security.sh"
        "shell.sh"
        "post-install.sh"
    )

    # Execute each setup script with error handling
    for script in "${setup_scripts[@]}"; do
        local script_path="$SCRIPT_DIR/$script"

        if [[ -f "$script_path" ]]; then
            log_info "Executing setup script: $script"

            # Execute script and continue even if it fails
            if bash "$script_path"; then
                log_success "Completed setup script: $script"
            else
                log_error "Failed to execute setup script: $script"
                log_error "Continuing with remaining scripts..."
                log_error "Check $ERROR_LOG_FILE for details"
            fi
        else
            log_error "Setup script not found: $script_path"
            log_error "Continuing with remaining scripts..."
        fi
    done

    log_success "Ubuntu system setup completed successfully!"
    log_info "Check $ERROR_LOG_FILE for any warnings or errors"
}

# Execute main function
main "$@"

