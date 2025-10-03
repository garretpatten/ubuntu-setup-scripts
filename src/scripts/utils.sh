#!/bin/bash

# Bash strict mode for better error handling
set -euo pipefail

# Global configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly ERROR_LOG_FILE="${PROJECT_ROOT}/setup_errors.log"
readonly TEMP_DIR="/tmp/ubuntu-setup-$$"

# Color codes for output formatting
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_NC} $*" >&2
}

log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_NC} $*" >&2
}

log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_NC} $*" >&2
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $*" >&2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$ERROR_LOG_FILE"
}

# Check if a command/application is installed
is_installed() {
    local application="$1"
    command -v "$application" >/dev/null 2>&1
}

# Check if a package is installed via apt
is_package_installed() {
    local package="$1"
    dpkg -l "$package" >/dev/null 2>&1
}

# Check if a flatpak application is installed
is_flatpak_installed() {
    local app_id="$1"
    flatpak list | grep -q "$app_id" 2>/dev/null
}

# Check if a directory exists and is not empty
is_directory_populated() {
    local directory="$1"
    [[ -d "$directory" && -n "$(ls -A "$directory" 2>/dev/null)" ]]
}

# Install packages in batch to reduce apt calls
install_apt_packages() {
    local packages=("$@")
    local packages_to_install=()

    log_info "Checking which packages need installation..."

    # Check which packages are not installed
    for package in "${packages[@]}"; do
        if ! is_package_installed "$package"; then
            packages_to_install+=("$package")
        else
            log_info "Package $package is already installed"
        fi
    done

    # Install packages in batch if any are needed
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        log_info "Installing packages: ${packages_to_install[*]}"
        sudo apt-get install -y "${packages_to_install[@]}" || {
            log_error "Failed to install packages: ${packages_to_install[*]}"
            return 1
        }
        log_success "Successfully installed packages: ${packages_to_install[*]}"
    else
        log_info "All packages are already installed"
    fi
}

# Update apt cache only if it's older than 1 hour
update_apt_cache() {
    local cache_file="/var/lib/apt/periodic/update-success-stamp"

    if [[ ! -f "$cache_file" ]] || [[ $(find "$cache_file" -mmin +60 2>/dev/null) ]]; then
        log_info "Updating apt cache..."
        sudo apt-get update -y || {
            log_error "Failed to update apt cache"
            return 1
        }
        log_success "Apt cache updated successfully"
    else
        log_info "Apt cache is recent, skipping update"
    fi
}

# Create directory if it doesn't exist
ensure_directory() {
    local directory="$1"
    if [[ ! -d "$directory" ]]; then
        mkdir -p "$directory" || {
            log_error "Failed to create directory: $directory"
            return 1
        }
        log_success "Created directory: $directory"
    fi
}

# Remove directory if it exists and is empty
remove_empty_directory() {
    local directory="$1"
    if [[ -d "$directory" ]]; then
        if rmdir "$directory" 2>/dev/null; then
            log_success "Removed empty directory: $directory"
        else
            log_warning "Directory not empty or failed to remove: $directory"
        fi
    else
        log_info "Directory already removed: $directory"
    fi
}

# Copy file with error handling
copy_file_safe() {
    local source="$1"
    local destination="$2"

    if [[ ! -f "$source" ]]; then
        log_error "Source file does not exist: $source"
        return 1
    fi

    # Create destination directory if needed
    local dest_dir
    dest_dir="$(dirname "$destination")"
    ensure_directory "$dest_dir"

    if cp "$source" "$destination"; then
        log_success "Copied $source to $destination"
    else
        log_error "Failed to copy $source to $destination"
        return 1
    fi
}

# Download file with verification
download_file_safe() {
    local url="$1"
    local destination="$2"
    local expected_hash="${3:-}"

    log_info "Downloading $url to $destination"

    if curl -fsSL "$url" -o "$destination"; then
        if [[ -n "$expected_hash" ]]; then
            local actual_hash
            actual_hash="$(sha256sum "$destination" | cut -d' ' -f1)"
            if [[ "$actual_hash" == "$expected_hash" ]]; then
                log_success "Downloaded and verified: $destination"
            else
                log_error "Hash verification failed for $destination"
                rm -f "$destination"
                return 1
            fi
        else
            log_success "Downloaded: $destination"
        fi
    else
        log_error "Failed to download $url"
        return 1
    fi
}

# Clone git repository with error handling
clone_repository_safe() {
    local repo_url="$1"
    local destination="$2"
    local depth="${3:-}"

    if [[ -d "$destination" ]]; then
        log_info "Repository already exists: $destination"
        return 0
    fi

    local clone_args=()
    if [[ -n "$depth" ]]; then
        clone_args+=("--depth" "$depth")
    fi

    log_info "Cloning repository $repo_url to $destination"

    if git clone "${clone_args[@]}" "$repo_url" "$destination"; then
        log_success "Successfully cloned repository to $destination"
    else
        log_error "Failed to clone repository $repo_url"
        return 1
    fi
}

# Cleanup function to be called on script exit
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        log_info "Cleaned up temporary directory: $TEMP_DIR"
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Create temporary directory
ensure_directory "$TEMP_DIR"

# Export functions and variables for use in other scripts
export -f log_info log_success log_warning log_error
export -f is_installed is_package_installed is_flatpak_installed is_directory_populated
export -f install_apt_packages update_apt_cache ensure_directory remove_empty_directory
export -f copy_file_safe download_file_safe clone_repository_safe
export PROJECT_ROOT SCRIPT_DIR ERROR_LOG_FILE TEMP_DIR

