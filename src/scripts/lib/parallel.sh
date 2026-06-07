#!/bin/bash

# shellcheck source=run.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/run.sh"

# Background job helpers with explicit exit-status tracking.

parallel_run_script() {
    local script="$1"
    ensure_temp_dir
    bash "$script" &
    echo $!
}

parallel_run_best_effort() {
    local script="$1"
    ensure_temp_dir
    bash "$script" || true &
    echo $!
}

parallel_wait_pids() {
    local label="$1"
    shift
    local pids=("$@")
    local pid

    for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
            echo "ERROR: ${label} (pid ${pid}) failed" >&2
            exit 1
        fi
    done
}

parallel_wait_pids_best_effort() {
    local label="$1"
    shift
    local pids=("$@")
    local pid

    for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
            echo "WARNING: ${label} (pid ${pid}) failed (continuing)" >&2
        fi
    done
}
