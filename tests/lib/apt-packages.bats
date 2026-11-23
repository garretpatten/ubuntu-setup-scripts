#!/usr/bin/env bats
# Unit tests for src/scripts/lib/apt-packages.sh.

setup() {
    load ../helpers/setup
    common_setup
    # shellcheck source=../../src/scripts/lib/apt-packages.sh
    source "$REAL_SCRIPTS_DIR/lib/apt-packages.sh"
    PACKAGES_FILE="$FIXTURES_DIR/packages/base.packages"
    OPTIONAL_FILE="$FIXTURES_DIR/packages/optional.packages"
    EMPTY_FILE="$FIXTURES_DIR/packages/empty.packages"
}

teardown() {
    common_teardown
}

@test "append_packages_from_file appends names and skips comments and blanks" {
    local -a PACKAGES=()
    append_packages_from_file "$PACKAGES_FILE"
    assert_equal "${#PACKAGES[@]}" "3"
    assert_equal "${PACKAGES[0]}" "git"
    assert_equal "${PACKAGES[1]}" "curl"
    assert_equal "${PACKAGES[2]}" "jq"
}

@test "append_packages_from_file no-ops on an empty list" {
    local -a PACKAGES=("already")
    append_packages_from_file "$EMPTY_FILE"
    assert_equal "${#PACKAGES[@]}" "1"
    assert_equal "${PACKAGES[0]}" "already"
}

@test "append_packages_from_file can append into a custom array name" {
    local -a CUSTOM=()
    append_packages_from_file "$PACKAGES_FILE" CUSTOM
    assert_equal "${#CUSTOM[@]}" "3"
    assert_equal "${CUSTOM[0]}" "git"
}

@test "install_apt_packages_individually calls apt-get once per package" {
    run install_apt_packages_individually "" git curl
    assert_success
    assert_stub_call 'apt-get install -y --no-install-recommends git$'
    assert_stub_call 'apt-get install -y --no-install-recommends curl$'
}

@test "install_apt_packages_individually continues after a package failure" {
    APT_GET_FAIL_PACKAGE=curl
    export APT_GET_FAIL_PACKAGE
    run install_apt_packages_individually "" git curl jq
    assert_success
    assert_stub_call 'apt-get install -y --no-install-recommends git$'
    assert_stub_call 'apt-get install -y --no-install-recommends curl$'
    assert_stub_call 'apt-get install -y --no-install-recommends jq$'
}

@test "install_apt_packages_from_file no-ops on an empty list" {
    run install_apt_packages_from_file "$EMPTY_FILE"
    assert_success
    refute_stub_call 'apt-get'
}

@test "install_apt_packages_from_file batch-installs the file's packages" {
    run install_apt_packages_from_file "$PACKAGES_FILE"
    assert_success
    assert_stub_call 'apt-get install -y --no-install-recommends git curl jq$'
    # One batch call, no per-package fallback.
    run grep -c '^apt-get install' "$STUB_CALL_LOG"
    assert_output "1"
}

@test "install_apt_packages_from_file falls back to individual installs on batch failure" {
    APT_GET_FAIL_PACKAGE=curl
    export APT_GET_FAIL_PACKAGE
    run install_apt_packages_from_file "$PACKAGES_FILE"
    assert_success
    assert_stub_call 'apt-get install -y --no-install-recommends git curl jq$'
    assert_stub_call 'apt-get install -y --no-install-recommends git$'
    assert_stub_call 'apt-get install -y --no-install-recommends curl$'
    assert_stub_call 'apt-get install -y --no-install-recommends jq$'
}

@test "install_apt_packages_from_files combines lists and batch-installs them" {
    run install_apt_packages_from_files "" "$PACKAGES_FILE" "$OPTIONAL_FILE"
    assert_success
    assert_stub_call 'apt-get install -y --no-install-recommends git curl jq ripgrep bat$'
}

@test "install_apt_packages_from_files no-ops when every list is empty" {
    run install_apt_packages_from_files "" "$EMPTY_FILE"
    assert_success
    refute_stub_call 'apt-get'
}

@test "install_apt_packages_from_files falls back per file on a non-optional batch failure" {
    APT_GET_FAIL_PACKAGE=ripgrep
    export APT_GET_FAIL_PACKAGE
    run install_apt_packages_from_files "" "$PACKAGES_FILE" "$OPTIONAL_FILE"
    assert_success
    # Combined batch fails because ripgrep is in the merged list.
    assert_stub_call 'apt-get install -y --no-install-recommends git curl jq ripgrep bat$'
    # Fallback installs each file; base.packages succeeds, optional falls back per package.
    assert_stub_call 'apt-get install -y --no-install-recommends git curl jq$'
    assert_stub_call 'apt-get install -y --no-install-recommends ripgrep bat$'
    assert_stub_call 'apt-get install -y --no-install-recommends ripgrep$'
    assert_stub_call 'apt-get install -y --no-install-recommends bat$'
}

@test "install_collected_packages no-ops when PACKAGES is empty" {
    PACKAGES=()
    run install_collected_packages
    assert_success
    refute_stub_call 'apt-get'
}

@test "install_collected_packages installs the collected packages" {
    PACKAGES=(git curl)
    run install_collected_packages
    assert_success
    assert_stub_call 'apt-get install -y --no-install-recommends git curl$'
}

@test "install_collected_packages optional returns 1 when apt-get fails" {
    PACKAGES=(git)
    APT_GET_FAIL=1
    export APT_GET_FAIL
    run install_collected_packages optional
    assert_failure 1
}

@test "install_collected_packages_individually continues after a package failure" {
    PACKAGES=(git curl jq)
    APT_GET_FAIL_PACKAGE=curl
    export APT_GET_FAIL_PACKAGE
    run install_collected_packages_individually
    assert_success
    assert_stub_call 'apt-get install -y --no-install-recommends git$'
    assert_stub_call 'apt-get install -y --no-install-recommends curl$'
    assert_stub_call 'apt-get install -y --no-install-recommends jq$'
}
