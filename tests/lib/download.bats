#!/usr/bin/env bats
# Unit tests for src/scripts/lib/download.sh.

setup() {
    load ../helpers/setup
    common_setup
    # shellcheck source=../../src/scripts/lib/download.sh
    source "$REAL_SCRIPTS_DIR/lib/download.sh"
}

teardown() {
    common_teardown
}

@test "download_file writes curl output to the target" {
    CURL_STUB_BODY="payload"
    export CURL_STUB_BODY
    local target="$SANDBOX/file.bin"
    run download_file "https://example.com/file.bin" "$target"
    assert_success
    assert_file_contains "$target" "payload"
    assert_stub_call 'curl .*-o '"$target"
}

@test "download_file returns curl's failure status" {
    CURL_STUB_MODE=fail
    export CURL_STUB_MODE
    run download_file "https://example.com/file.bin" "$SANDBOX/file.bin"
    assert_failure 22
}

@test "download_installer rejects a failed download and removes the target" {
    CURL_STUB_MODE=fail
    export CURL_STUB_MODE
    local target="$SANDBOX/installer.sh"
    run --separate-stderr download_installer "https://example.com/installer.sh" "$target"
    assert_failure 1
    assert_stderr --partial "ERROR: download of https://example.com/installer.sh failed"
    assert_file_not_exists "$target"
}

@test "download_installer rejects an empty file and removes it" {
    CURL_STUB_MODE=empty
    export CURL_STUB_MODE
    local target="$SANDBOX/installer.sh"
    run --separate-stderr download_installer "https://example.com/installer.sh" "$target"
    assert_failure 1
    assert_stderr --partial "produced an empty file"
    assert_file_not_exists "$target"
}

@test "download_installer accepts a non-empty file" {
    CURL_STUB_BODY="#!/bin/bash"
    export CURL_STUB_BODY
    local target="$SANDBOX/installer.sh"
    run download_installer "https://example.com/installer.sh" "$target"
    assert_success
    assert_file_exists "$target"
}

@test "github_latest_release_tag prints the tag from the redirect URL" {
    CURL_STUB_REDIRECT="https://github.com/example/repo/releases/tag/v9.8.7"
    export CURL_STUB_REDIRECT
    run github_latest_release_tag "example/repo"
    assert_success
    assert_output "v9.8.7"
    assert_stub_call 'curl .*https://github.com/example/repo/releases/latest'
}

@test "github_latest_release_tag fails when the redirect is not a tag URL" {
    CURL_STUB_REDIRECT="https://github.com/example/repo/releases"
    export CURL_STUB_REDIRECT
    run --separate-stderr github_latest_release_tag "example/repo"
    assert_failure 1
    assert_stderr --partial "could not resolve latest release tag"
}
