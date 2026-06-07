#!/bin/bash

install_snap_if_missing() {
    local snap_name="$1"
    local classic="${2:-}"
    local binary="${3:-$snap_name}"

    if command -v "$binary" >/dev/null 2>&1; then
        return 0
    fi
    if snap list "$snap_name" 2>/dev/null | grep -q "^${snap_name} "; then
        return 0
    fi

    sudo systemctl start snapd.socket snapd.seeded.service 2>/dev/null || true
    if [[ "$classic" == classic ]]; then
        sudo snap install "$snap_name" --classic || true
    else
        sudo snap install "$snap_name" || true
    fi
}

install_snaps_from_file() {
    local snaps_file="$1"
    local line snap_name arg1 arg2 classic binary

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// /}" ]] && continue

        read -r snap_name arg1 arg2 <<< "$line"
        classic=""
        binary="$snap_name"
        if [[ "$arg1" == classic ]]; then
            classic=classic
            if [[ -n "$arg2" ]]; then
                binary="$arg2"
            fi
        fi
        install_snap_if_missing "$snap_name" "$classic" "$binary"
    done < "$snaps_file"
}
