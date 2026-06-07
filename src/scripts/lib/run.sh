#!/bin/bash

ensure_temp_dir() {
    if [[ -z "${TEMP_DIR:-}" ]]; then
        export TEMP_DIR="/tmp/ubuntu-setup-$$"
    fi
    mkdir -p "$TEMP_DIR"
}

run_script() {
    ensure_temp_dir
    bash "$1" || true
}
