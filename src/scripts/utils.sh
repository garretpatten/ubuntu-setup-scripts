#!/bin/bash

# Global configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly ERROR_LOG_FILE="${PROJECT_ROOT}/setup_errors.log"
readonly TEMP_DIR="/tmp/ubuntu-setup-$$"

# Color codes for output formatting
readonly COLOR_RED='\033[0;31m'
readonly COLOR_NC='\033[0m' # No Color

# Log errors only
log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $*" >&2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$ERROR_LOG_FILE"
}

# Install packages - multi-run safe
install_apt_packages() {
    local packages=("$@")
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}" 2>>"$ERROR_LOG_FILE" || {
        log_error "Failed to install packages: ${packages[*]}"
    }
}

# Update apt cache
update_apt_cache() {
    sudo apt-get update -y 2>>"$ERROR_LOG_FILE" || {
        log_error "Failed to update apt cache"
    }
}

# Create directory
ensure_directory() {
    mkdir -p "$1" 2>>"$ERROR_LOG_FILE" || {
        log_error "Failed to create directory: $1"
    }
}

# Remove empty directory
remove_empty_directory() {
    rmdir "$1" 2>/dev/null || true
}

# Copy file
copy_file_safe() {
    local source="$1"
    local destination="$2"

    if [[ ! -f "$source" ]]; then
        log_error "Source file does not exist: $source"
        return
    fi

    mkdir -p "$(dirname "$destination")"
    cp "$source" "$destination" 2>>"$ERROR_LOG_FILE" || {
        log_error "Failed to copy $source to $destination"
    }
}

# Download file
download_file_safe() {
    local url="$1"
    local destination="$2"

    curl -sSL --connect-timeout 30 --max-time 300 --fail --show-error "$url" -o "$destination" 2>>"$ERROR_LOG_FILE" || {
        log_error "Failed to download $url"
        rm -f "$destination" 2>/dev/null || true
        return 1
    }

    if [[ ! -f "$destination" ]] || [[ ! -s "$destination" ]]; then
        log_error "Downloaded file is empty or missing: $destination"
        rm -f "$destination" 2>/dev/null || true
        return 1
    fi
}

# Clone git repository
clone_repository_safe() {
    local repo_url="$1"
    local destination="$2"
    local depth="${3:-}"

    if [[ -d "$destination" ]]; then
        return 0
    fi

    local clone_args=()
    if [[ -n "$depth" ]]; then
        clone_args+=("--depth" "$depth")
    fi

    git clone "${clone_args[@]}" "$repo_url" "$destination" 2>>"$ERROR_LOG_FILE" || {
        log_error "Failed to clone repository $repo_url"
    }
}

# Create temporary directory
mkdir -p "$TEMP_DIR"

# Export functions and variables for use in other scripts
export -f log_error install_apt_packages update_apt_cache ensure_directory remove_empty_directory
export -f copy_file_safe download_file_safe clone_repository_safe
export PROJECT_ROOT SCRIPT_DIR ERROR_LOG_FILE TEMP_DIR
