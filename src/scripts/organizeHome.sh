#!/bin/bash

# Home Directory Organization Script
# Removes unused default directories and creates useful project directories
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Remove unneeded default directories
remove_unused_directories() {
    log_info "Removing unused default directories..."

    # Define directories to remove (only if empty)
    local directories_to_remove=(
        "Music"
        "Public"
        "Templates"
    )

    # Remove each directory if it exists and is empty
    for directory_name in "${directories_to_remove[@]}"; do
        local directory_path="$HOME/$directory_name"
        remove_empty_directory "$directory_path"
    done
}

# Create useful project directories
create_project_directories() {
    log_info "Creating project directories..."

    # Define directories to create
    local directories_to_create=(
        "AppImages"     # For portable applications
        "Hacking"       # For security tools and resources
        "Projects"      # For development projects
        "Scripts"       # For personal scripts
        "Tools"         # For downloaded tools and utilities
    )

    # Create each directory
    for directory_name in "${directories_to_create[@]}"; do
        local directory_path="$HOME/$directory_name"
        ensure_directory "$directory_path"
    done
}

# Set up development workspace structure
setup_development_workspace() {
    log_info "Setting up development workspace structure..."

    # Create subdirectories in Projects folder
    local project_subdirs=(
        "Projects/personal"     # Personal projects
        "Projects/work"         # Work-related projects
        "Projects/learning"     # Learning and tutorial projects
        "Projects/opensource"   # Open source contributions
    )

    for subdir in "${project_subdirs[@]}"; do
        ensure_directory "$HOME/$subdir"
    done

    # Create subdirectories in Scripts folder
    local script_subdirs=(
        "Scripts/automation"    # Automation scripts
        "Scripts/utilities"     # Utility scripts
        "Scripts/backup"        # Backup scripts
    )

    for subdir in "${script_subdirs[@]}"; do
        ensure_directory "$HOME/$subdir"
    done
}

# Create useful symbolic links
create_useful_symlinks() {
    log_info "Creating useful symbolic links..."

    # Create Desktop shortcut to Projects (if Desktop exists)
    if [[ -d "$HOME/Desktop" ]]; then
        local projects_link="$HOME/Desktop/Projects"
        if [[ ! -L "$projects_link" && ! -e "$projects_link" ]]; then
            ln -s "$HOME/Projects" "$projects_link" && \
                log_success "Created Desktop shortcut to Projects" || \
                log_warning "Failed to create Desktop shortcut to Projects"
        fi
    fi

    # Create quick access to Downloads in Projects (for downloaded code)
    local downloads_link="$HOME/Projects/downloads"
    if [[ ! -L "$downloads_link" && ! -e "$downloads_link" ]]; then
        ln -s "$HOME/Downloads" "$downloads_link" && \
            log_success "Created Projects shortcut to Downloads" || \
            log_warning "Failed to create Projects shortcut to Downloads"
    fi
}

# Set appropriate permissions for directories
set_directory_permissions() {
    log_info "Setting appropriate directory permissions..."

    # Set secure permissions for Scripts directory
    if [[ -d "$HOME/Scripts" ]]; then
        chmod 755 "$HOME/Scripts"
        find "$HOME/Scripts" -type d -exec chmod 755 {} \; 2>/dev/null || true
        log_info "Set secure permissions for Scripts directory"
    fi

    # Set permissions for Hacking directory (more restrictive)
    if [[ -d "$HOME/Hacking" ]]; then
        chmod 700 "$HOME/Hacking"
        log_info "Set restrictive permissions for Hacking directory"
    fi
}

# Main function
main() {
    log_info "Starting home directory organization..."

    # Organize home directory
    remove_unused_directories
    create_project_directories
    setup_development_workspace
    create_useful_symlinks
    set_directory_permissions

    log_success "Home directory organization completed!"
    log_info "Your home directory has been organized with useful project folders"
}

# Execute main function
main "$@"

