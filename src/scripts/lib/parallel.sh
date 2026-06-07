#!/bin/bash

# shellcheck source=run.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/run.sh"

# Background job helpers with explicit exit-status tracking.
# Capture PIDs in the caller shell (parallel_run_*; PIDS+=($!)), not via $(...),
# or wait(1) will fail because the background job was started in a subshell.

parallel_run_best_effort() {
    local script="$1"
    ensure_temp_dir
    bash "$script" || true &
    echo $!
}

parallel_wait_pids() {
    local best_effort="${1:-0}"
    local label="$2"
    shift 2
    local pids=("$@")
    local pid

    for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
            if [[ "$best_effort" == 1 ]]; then
                echo "WARNING: ${label} (pid ${pid}) failed (continuing)" >&2
            else
                echo "ERROR: ${label} (pid ${pid}) failed" >&2
                exit 1
            fi
        fi
    done
}

parallel_wait_pids_best_effort() {
    parallel_wait_pids 1 "$@"
}
