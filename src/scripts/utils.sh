#!/bin/bash

# Global configuration — this file lives at src/scripts/utils.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
readonly SCRIPT_DIR
readonly SCRIPTS_DIR="$SCRIPT_DIR"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)" || exit 1
readonly PROJECT_ROOT
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

# Copy file (skip if destination already exists — first-time provisioning only).
copy_file_safe() {
    local source="$1"
    local destination="$2"

    if [[ ! -f "$source" ]] || [[ -f "$destination" ]]; then
        return 0
    fi

    mkdir -p "$(dirname "$destination")"
    cp "$source" "$destination" 2>>"$ERROR_LOG_FILE" || {
        log_error "failed to copy $source to $destination"
    }
}

# Copy directory tree when destination path does not already exist (idempotent provisioning).
copy_directory_safe() {
    local source="$1"
    local destination="$2"

    if [[ ! -d "$source" ]] || [[ -d "$destination" ]]; then
        return 0
    fi

    local dest_dir
    dest_dir=$(dirname "$destination")
    mkdir -p "$dest_dir"
    cp -r "$source" "$destination" 2>>"$ERROR_LOG_FILE" || {
        log_error "failed to copy directory $source to $destination"
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

# GNOME gsettings helpers — only when desktop schemas are installed (e.g. not on minimal/CI images).
gsettings_ok() {
    command -v gsettings >/dev/null 2>&1 || return 1
    [[ -S "/run/user/$(id -u)/bus" ]] || return 1
    gsettings list-schemas 2>/dev/null | grep -qx org.gnome.desktop.interface
}

gsettings_set() {
    gsettings set "$@" 2>>"$ERROR_LOG_FILE" || true
}

gsettings_schema_exists() {
    gsettings list-schemas 2>/dev/null | grep -qx "$1"
}

# True when this user has an active graphical session (local terminal or SSH while logged in).
desktop_session_active() {
    [[ -n "${WAYLAND_DISPLAY:-}" || -n "${DISPLAY:-}" ]] && return 0
    command -v loginctl >/dev/null 2>&1 || return 1

    local sid session_type user
    while read -r sid _ _ user _; do
        [[ "$user" == "$USER" ]] || continue
        session_type=$(loginctl show-session "$sid" -p Type --value 2>/dev/null || true)
        if [[ "$session_type" == wayland || "$session_type" == x11 ]]; then
            return 0
        fi
    done < <(loginctl list-sessions --no-legend 2>/dev/null)

    return 1
}

# Comment out pass-cli GITHUB_TOKEN lines that block graphical login before Proton Pass is ready.
ensure_zshrc_login_safe() {
    local zshrc="$HOME/.zshrc"
    [[ -f "$zshrc" ]] || return 0
    grep -qE '^GITHUB_TOKEN=\$\(pass-cli item view' "$zshrc" 2>/dev/null || return 0

    sed -i.bak-setup-scripts \
        -e '/pass-cli item view/s/^/# disabled-by-setup-scripts: /' \
        -e '/^export GITHUB_TOKEN$/s/^/# disabled-by-setup-scripts: /' \
        "$zshrc" 2>>"$ERROR_LOG_FILE" || true
}

# True when zsh can start an interactive login without hanging (guards chsh during provisioning).
zsh_login_safe() {
    local zsh_path="$1"
    [[ -n "$zsh_path" && -x "$zsh_path" ]] || return 1
    ensure_zshrc_login_safe
    if command -v timeout >/dev/null 2>&1; then
        timeout 5 "$zsh_path" -ic 'exit 0' >/dev/null 2>&1
        return $?
    fi
    "$zsh_path" -fc 'exit 0' >/dev/null 2>&1
}

# Create temporary directory
mkdir -p "$TEMP_DIR"

# Export functions and variables for use in other scripts
export -f log_error install_apt_packages update_apt_cache ensure_directory remove_empty_directory
export -f copy_file_safe copy_directory_safe download_file_safe clone_repository_safe
export -f gsettings_ok gsettings_set gsettings_schema_exists desktop_session_active
export -f ensure_zshrc_login_safe zsh_login_safe
export PROJECT_ROOT SCRIPT_DIR SCRIPTS_DIR ERROR_LOG_FILE TEMP_DIR
