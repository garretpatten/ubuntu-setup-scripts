#!/usr/bin/env bats
# Unit tests for src/scripts/lib/parallel.sh.

setup() {
    load ../helpers/setup
    common_setup
    # shellcheck source=../../src/scripts/lib/parallel.sh
    source "$REAL_SCRIPTS_DIR/lib/parallel.sh"
}

teardown() {
    common_teardown
}

write_child() {
    local path="$1"
    local body="$2"
    printf '%s\n' "#!/bin/bash" "$body" >"$path"
    chmod +x "$path"
}

# Start a child and wait inside the same shell (and the same `run` subshell)
# so wait(1) can see the background PID.
run_and_wait() {
    local best_effort="$1"
    local script="$2"
    parallel_run_best_effort "$script"
    local pid=$!
    parallel_wait_pids "$best_effort" "test" "$pid"
}

@test "parallel_run_best_effort writes a log and start file and runs the script" {
    local script="$SANDBOX/ok.sh"
    write_child "$script" 'echo hello'
    parallel_run_best_effort "$script"
    local pid=$!
    wait "$pid"
    assert_file_exists "$TEMP_DIR/.parallel-log-$pid"
    assert_file_exists "$TEMP_DIR/.parallel-start-$pid"
    local log_file
    log_file="$(cat "$TEMP_DIR/.parallel-log-$pid")"
    assert_file_exists "$log_file"
    assert_file_contains "$log_file" "hello"
}

@test "parallel_pid_log prints the child's captured output" {
    local script="$SANDBOX/ok.sh"
    write_child "$script" 'echo hello-from-child'
    parallel_run_best_effort "$script"
    local pid=$!
    wait "$pid"
    run parallel_pid_log "$pid"
    assert_success
    assert_output --partial "hello-from-child"
}

@test "parallel_wait_pids succeeds when the child succeeds" {
    local script="$SANDBOX/ok.sh"
    write_child "$script" 'exit 0'
    run run_and_wait 0 "$script"
    assert_success
}

@test "parallel_wait_pids best-effort continues when the child fails" {
    local script="$SANDBOX/fail.sh"
    write_child "$script" 'echo failed-child; exit 2'
    run --separate-stderr run_and_wait 1 "$script"
    assert_success
    assert_stderr --partial "WARNING: test (pid "
    assert_stderr --partial "failed-child"
}

@test "parallel_wait_pids strict mode exits 1 when the child fails" {
    local script="$SANDBOX/fail.sh"
    write_child "$script" 'echo failed-child; exit 2'
    run --separate-stderr run_and_wait 0 "$script"
    assert_failure 1
    assert_stderr --partial "ERROR: test (pid "
    assert_stderr --partial "failed-child"
}

@test "parallel_wait_pids_best_effort continues when the child fails" {
    local script="$SANDBOX/fail.sh"
    write_child "$script" 'exit 2'
    wait_best_effort() {
        parallel_run_best_effort "$1"
        local pid=$!
        parallel_wait_pids_best_effort "test" "$pid"
    }
    run --separate-stderr wait_best_effort "$script"
    assert_success
    assert_stderr --partial "WARNING: test (pid "
}
