#!/bin/bash

# Ubuntu Setup Master Script
# This script orchestrates the complete Ubuntu system setup process
# Author: Garret Patten
# Usage: ./master.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

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

# Execute each setup script
for script in "${setup_scripts[@]}"; do
    local script_path="$SCRIPT_DIR/$script"

    if [[ -f "$script_path" ]]; then
        bash "$script_path" || {
            log_error "Failed to execute setup script: $script"
        }
    else
        log_error "Setup script not found: $script_path"
    fi
done
