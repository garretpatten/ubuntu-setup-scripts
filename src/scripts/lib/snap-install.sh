#!/bin/bash

# Snap install helpers.
# Each install is capped hard with "timeout" so one hung snap never eats the
# whole provisioning budget; a failing install is retried once for transient
# snap-store/download errors. Callers decide what a failure means (the snaps
# script remains best-effort).

# Seconds snapd is told to wait for its change; failures here get one retry.
declare -r SNAP_INSTALL_TIMEOUT=240
# Hard wall-clock cap of the whole "snap install" invocation (coreutils).
declare -r SNAP_HARD_TIMEOUT=300

snapd_ready() {
    sudo systemctl start snapd.socket snapd.seeded.service 2>/dev/null ||
        {
            echo 'WARNING: could not start snapd services' >&2
            return 1
        }
}

install_snap() {
    local snap_name="$1"
    local classic="${2:-}"
    local -a install_flags=()
    local -a classic_flags=()
    local rc

    if [[ "$classic" == classic ]]; then
        classic_flags=(--classic)
    fi
    install_flags=("${classic_flags[@]}" "--timeout=${SNAP_INSTALL_TIMEOUT}s")

    echo "Installing snap: $snap_name ${classic_flags[*]:-} (timeout ${SNAP_INSTALL_TIMEOUT}s)"
    sudo timeout "${SNAP_HARD_TIMEOUT}" \
        snap install "${install_flags[@]}" "$snap_name"
    rc=$?
    if [[ "$rc" == 0 ]]; then
        echo "Snap install of $snap_name succeeded"
        return 0
    fi
    if [[ "$rc" == 124 ]]; then
        echo "Snap install of $snap_name hit the hard timeout; not retrying" >&2
        return "$rc"
    fi
    echo "Snap install of $snap_name received rc=$rc; retrying once" >&2
    sudo timeout "${SNAP_HARD_TIMEOUT}" \
        snap install "${install_flags[@]}" "$snap_name"
    rc=$?
    return "$rc"
}

install_snap_if_missing() {
    local snap_name="$1"
    local classic="${2:-}"
    local binary="${3:-$snap_name}"

    if command -v "$binary" >/dev/null 2>&1; then
        echo "Snap already installed (binary found): $binary"
        return 0
    fi
    if snap list "$snap_name" 2>/dev/null | grep -q "^${snap_name} "; then
        echo "Snap already installed: $snap_name"
        return 0
    fi

    snapd_ready
    if install_snap "$snap_name" "$classic"; then
        echo "Snap installed: $snap_name"
    else
        echo "WARNING: snap install of $snap_name failed (continuing)" >&2
        return 1
    fi
}

install_snaps_from_file() {
    local snaps_file="$1"
    local line snap_name arg1 arg2 classic binary
    local -i failed=0

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
        if ! install_snap_if_missing "$snap_name" "$classic" "$binary"; then
            failed+=1
        fi
    done < "$snaps_file"

    return "$failed"
}
