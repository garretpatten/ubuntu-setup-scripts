#!/bin/bash

# Background job helpers with explicit exit-status tracking.

parallel_run_script() {
    local script="$1"
    bash "$script" &
    echo $!
}

parallel_run_best_effort() {
    local script="$1"
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
