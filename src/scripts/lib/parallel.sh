#!/bin/bash

# shellcheck source=run.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/run.sh"

# Background job helpers with explicit exit-status tracking.
# Call parallel_run_* directly (NOT via $(...)) and capture the PID from $! in
# the caller shell (PIDS+=($!)); wait(1) cannot track jobs started inside a
# command substitution subshell.

parallel_run_best_effort() {
    local script="$1"
    local log_file
    ensure_temp_dir
    mkdir -p "$TEMP_DIR/logs"
    log_file="$TEMP_DIR/logs/$(basename "$script").log"
    # Redirect child output to a log so parallel runs do not interleave their
    # output; the exit status is kept intact for parallel_wait_pids.
    bash "$script" >"$log_file" 2>&1 &
    printf '%s\n' "$log_file" >"$TEMP_DIR/.parallel-log-$!"
}

parallel_pid_log() {
    local pid="$1"
    local mapping_file="$TEMP_DIR/.parallel-log-$pid"
    local log_file
    if [[ -f "$mapping_file" ]]; then
        log_file="$(cat "$mapping_file")"
        if [[ -f "$log_file" ]]; then
            cat "$log_file"
        fi
    fi
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
                parallel_pid_log "$pid" | tail -n 20 >&2
            else
                echo "ERROR: ${label} (pid ${pid}) failed" >&2
                parallel_pid_log "$pid" | tail -n 20 >&2
                exit 1
            fi
        fi
    done
}

parallel_wait_pids_best_effort() {
    parallel_wait_pids 1 "$@"
}
