#!/bin/bash

# Read package names from a file (one per line; # comments and blanks ignored) and apt install.

append_packages_from_file() {
    local packages_file="$1"
    local array_name="${2:-PACKAGES}"
    local -n _packages_ref="$array_name"

    mapfile -t file_packages < <(grep -v '^#' "$packages_file" | grep -v '^[[:space:]]*$')
    if [[ ${#file_packages[@]} -eq 0 ]]; then
        return 0
    fi
    _packages_ref+=("${file_packages[@]}")
}

install_apt_packages_individually() {
    local optional="${1:-}"
    shift
    local -a packages=("$@")
    local pkg

    for pkg in "${packages[@]}"; do
        if [[ "$optional" == optional ]]; then
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$pkg" || true
        else
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$pkg" || true
        fi
    done
}

install_apt_packages_from_file() {
    local packages_file="$1"
    local optional="${2:-}"

    mapfile -t packages < <(grep -v '^#' "$packages_file" | grep -v '^[[:space:]]*$')
    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi

    if [[ "$optional" == optional ]]; then
        if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${packages[@]}"; then
            install_apt_packages_individually optional "${packages[@]}"
        fi
        return 0
    fi

    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${packages[@]}"; then
        return 0
    fi

    install_apt_packages_individually "" "${packages[@]}"
}

install_apt_packages_from_files() {
    local optional="${1:-}"
    shift
    local packages_file
    local -a packages=()
    local -a file_packages=()

    for packages_file in "$@"; do
        mapfile -t file_packages < <(grep -v '^#' "$packages_file" | grep -v '^[[:space:]]*$')
        if [[ ${#file_packages[@]} -gt 0 ]]; then
            packages+=("${file_packages[@]}")
        fi
    done

    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi

    if [[ "$optional" == optional ]]; then
        if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${packages[@]}"; then
            install_apt_packages_individually optional "${packages[@]}"
        fi
        return 0
    fi

    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${packages[@]}"; then
        return 0
    fi

    for packages_file in "$@"; do
        install_apt_packages_from_file "$packages_file"
    done
}

install_collected_packages() {
    local optional="${1:-}"

    # PACKAGES is populated by the install orchestrator before calling this helper.
    # shellcheck disable=SC2153,SC2154
    if [[ ${#PACKAGES[@]} -eq 0 ]]; then
        return 0
    fi

    if [[ "$optional" == optional ]]; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${PACKAGES[@]}" || return 1
    else
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${PACKAGES[@]}"
    fi
}

# Install each package separately so one unavailable third-party package does not block the rest.
install_collected_packages_individually() {
    local optional="${1:-}"
    local pkg

    # shellcheck disable=SC2153,SC2154
    for pkg in "${PACKAGES[@]}"; do
        if [[ "$optional" == optional ]]; then
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$pkg" || true
        else
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$pkg" || true
        fi
    done
}
