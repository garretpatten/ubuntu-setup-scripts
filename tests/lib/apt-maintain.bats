#!/usr/bin/env bats
# Unit tests for src/scripts/lib/apt-maintain.sh.

setup() {
    load ../helpers/setup
    common_setup
    # shellcheck source=../../src/scripts/lib/apt-maintain.sh
    source "$REAL_SCRIPTS_DIR/lib/apt-maintain.sh"
}

teardown() {
    common_teardown
}

@test "apt_maintain_update calls apt-get update -y" {
    run apt_maintain_update
    assert_success
    assert_stub_call 'sudo apt-get update -y'
}

@test "apt_maintain_update continues when apt-get fails" {
    APT_GET_FAIL=1
    export APT_GET_FAIL
    run apt_maintain_update
    assert_success
}

@test "apt_maintain_cleanup calls autoremove and autoclean" {
    run apt_maintain_cleanup
    assert_success
    assert_stub_call 'sudo apt-get autoremove -y'
    assert_stub_call 'sudo apt-get autoclean'
}

@test "apt_maintain_cleanup continues when apt-get fails" {
    APT_GET_FAIL=1
    export APT_GET_FAIL
    run apt_maintain_cleanup
    assert_success
}
