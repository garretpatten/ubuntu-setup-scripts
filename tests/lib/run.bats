#!/usr/bin/env bats
# Unit tests for src/scripts/lib/run.sh.
# shellcheck disable=SC2030,SC2031

setup() {
    load ../helpers/setup
    common_setup
    # shellcheck source=../../src/scripts/lib/run.sh
    source "$REAL_SCRIPTS_DIR/lib/run.sh"
}

teardown() {
    if [[ -n "${DEFAULT_TEMP_DIR:-}" && -d "$DEFAULT_TEMP_DIR" ]]; then
        rm -rf "$DEFAULT_TEMP_DIR"
    fi
    common_teardown
}

@test "ensure_temp_dir keeps an existing TEMP_DIR and creates it" {
    export TEMP_DIR="$SANDBOX/custom-temp"
    run ensure_temp_dir
    assert_success
    assert_dir_exists "$SANDBOX/custom-temp"
    assert_equal "$TEMP_DIR" "$SANDBOX/custom-temp"
}

@test "ensure_temp_dir assigns a default TEMP_DIR when unset" {
    unset TEMP_DIR
    ensure_temp_dir
    DEFAULT_TEMP_DIR="$TEMP_DIR"
    assert_equal "$TEMP_DIR" "/tmp/ubuntu-setup-$$"
    assert_dir_exists "$TEMP_DIR"
}

@test "run_script runs the given script and forwards arguments" {
    local script="$SANDBOX/child.sh"
    cat >"$script" <<'SCRIPT'
#!/bin/bash
printf 'ran %s\n' "$*" >"${CALL_LOG:?}"
SCRIPT
    chmod +x "$script"
    export CALL_LOG="$SANDBOX/child-calls.log"
    run run_script "$script" --flag value
    assert_success
    assert_file_contains "$CALL_LOG" "ran --flag value"
}

@test "run_script continues when the child script fails" {
    local script="$SANDBOX/child.sh"
    cat >"$script" <<'SCRIPT'
#!/bin/bash
exit 7
SCRIPT
    chmod +x "$script"
    run run_script "$script"
    assert_success
}
