#!/bin/bash

# Read package names from a file (one per line; # comments and blanks ignored) and apt install.

install_apt_packages_from_file() {
    local packages_file="$1"
    local optional="${2:-}"

    mapfile -t packages < <(grep -v '^#' "$packages_file" | grep -v '^[[:space:]]*$')
    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi

    if [[ "$optional" == optional ]]; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}" || true
    else
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
    fi
}
