#!/usr/bin/env bats
# Unit tests for src/scripts/lib/snap-install.sh.

setup() {
    load ../helpers/setup
    common_setup
    # shellcheck source=../../src/scripts/lib/snap-install.sh
    source "$REAL_SCRIPTS_DIR/lib/snap-install.sh"
}

teardown() {
    common_teardown
}

@test "snapd_ready starts snapd services" {
    run snapd_ready
    assert_success
    assert_stub_call 'sudo systemctl start snapd.socket snapd.seeded.service'
}

@test "snapd_ready warns and returns 1 when systemctl fails" {
    SYSTEMCTL_FAIL=1
    export SYSTEMCTL_FAIL
    run --separate-stderr snapd_ready
    assert_failure 1
    assert_stderr --partial "WARNING: could not start snapd services"
}

@test "install_snap uses --classic when requested" {
    run install_snap code classic
    assert_success
    assert_stub_call 'sudo timeout 300 snap install --classic code'
}

@test "install_snap does not retry on timeout (124)" {
    SNAP_INSTALL_RC=124
    export SNAP_INSTALL_RC
    run --separate-stderr install_snap zoom
    assert_failure 124
    assert_stderr --partial "not retrying"
    run grep -c '^snap install' "$STUB_CALL_LOG"
    assert_output "1"
}

@test "install_snap does not retry on a usage error (64)" {
    SNAP_INSTALL_RC=64
    export SNAP_INSTALL_RC
    run --separate-stderr install_snap zoom
    assert_failure 64
    assert_stderr --partial "not retrying"
    run grep -c '^snap install' "$STUB_CALL_LOG"
    assert_output "1"
}

@test "install_snap retries once on a transient failure" {
    SNAP_INSTALL_FAIL_TIMES=1
    export SNAP_INSTALL_FAIL_TIMES
    run --separate-stderr install_snap zoom
    assert_success
    assert_stderr --partial "retrying once"
    run grep -c '^snap install' "$STUB_CALL_LOG"
    assert_output "2"
}

@test "install_snap_if_missing skips when the binary is already on PATH" {
    mkdir -p "$SANDBOX/bin"
    cat >"$SANDBOX/bin/zoom" <<'STUB'
#!/bin/bash
exit 0
STUB
    chmod +x "$SANDBOX/bin/zoom"
    PATH="$SANDBOX/bin:$PATH"
    run install_snap_if_missing zoom
    assert_success
    assert_output --partial "Snap already installed (binary found): zoom"
    refute_stub_call 'snap install'
}

@test "install_snap_if_missing skips when snap list shows the snap" {
    # Hide any host zoom binary so the snap list path is used.
    hide_binary zoom
    SNAP_LIST="zoom"
    export SNAP_LIST
    run install_snap_if_missing zoom
    assert_success
    assert_output --partial "Snap already installed: zoom"
    refute_stub_call 'snap install'
}

@test "install_snap_if_missing installs a missing snap" {
    hide_binary zoom
    run install_snap_if_missing zoom
    assert_success
    assert_output --partial "Snap installed: zoom"
    assert_stub_call 'snap install zoom'
}

@test "install_snaps_from_file parses classic flags and binary overrides" {
    hide_binary code
    hide_binary zoom
    hide_binary owasp-zap
    hide_binary zap
    run install_snaps_from_file "$FIXTURES_DIR/snaps.txt"
    assert_success
    assert_stub_call 'snap install --classic code'
    assert_stub_call 'snap install zoom$'
    assert_stub_call 'snap install --classic zap'
}

@test "install_snaps_from_file returns the number of failed installs" {
    hide_binary zoom
    hide_binary code
    hide_binary owasp-zap
    hide_binary zap
    SNAP_INSTALL_RC=1
    export SNAP_INSTALL_RC
    run install_snaps_from_file "$FIXTURES_DIR/snaps.txt"
    assert_failure 3
}
