#!/bin/bash

ensure_temp_dir() {
    if [[ -z "${TEMP_DIR:-}" ]]; then
        export TEMP_DIR="/tmp/ubuntu-setup-$$"
    fi
    mkdir -p "$TEMP_DIR"
}

run_script() {
    if [[ -z "${PROJECT_ROOT:-}" ]]; then
        # shellcheck source=env.sh
        source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"
    fi
    ensure_temp_dir
    bash "$1" || true
}
