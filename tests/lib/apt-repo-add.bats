#!/usr/bin/env bats
# Unit tests for src/scripts/lib/apt-repo-add.sh.
# shellcheck disable=SC2032,SC2329

setup() {
    load ../helpers/setup
    common_setup
    # shellcheck source=../../src/scripts/lib/apt-repo-add.sh
    source "$REAL_SCRIPTS_DIR/lib/apt-repo-add.sh"
    KEYRING_DIR="$SANDBOX/keyrings"
    LIST_DIR="$SANDBOX/lists"
    mkdir -p "$KEYRING_DIR" "$LIST_DIR"
}

teardown() {
    common_teardown
}

@test "expand_repo_deb_line replaces ARCH and CODENAME" {
    DPKG_ARCH=arm64 LSB_CODENAME=jammy
    export DPKG_ARCH LSB_CODENAME
    run expand_repo_deb_line "deb [arch=ARCH] https://example.com/ CODENAME main"
    assert_success
    assert_output "deb [arch=arm64] https://example.com/ jammy main"
}

@test "expand_repo_deb_line leaves other text alone" {
    run expand_repo_deb_line "deb https://example.com/ stable main"
    assert_success
    assert_output "deb https://example.com/ stable main"
}

@test "add_repo_keyring_from_curl writes the keyring when it is missing" {
    local keyring="$KEYRING_DIR/example.gpg"
    CURL_STUB_BODY="-----BEGIN PGP PUBLIC KEY BLOCK-----"
    export CURL_STUB_BODY
    run add_repo_keyring_from_curl "https://example.com/key.gpg" "$keyring"
    assert_success
    assert_file_exists "$keyring"
    assert_file_contains "$keyring" "stub-keyring"
    assert_stub_call 'curl .*-fsSL https://example.com/key.gpg'
    assert_stub_call 'sudo gpg --dearmor -o '
}

@test "add_repo_keyring_from_curl is idempotent when the keyring exists" {
    local keyring="$KEYRING_DIR/example.gpg"
    printf 'existing\n' >"$keyring"
    run add_repo_keyring_from_curl "https://example.com/key.gpg" "$keyring"
    assert_success
    assert_file_contains "$keyring" "existing"
    refute_stub_call '^curl '
    refute_stub_call '^gpg '
}

@test "add_repo_keyring_from_wget writes the keyring when it is missing" {
    local keyring="$KEYRING_DIR/example.gpg"
    run add_repo_keyring_from_wget "https://example.com/key.asc" "$keyring"
    assert_success
    assert_file_exists "$keyring"
    assert_file_contains "$keyring" "stub-keyring"
    assert_stub_call 'wget .*https://example.com/key.asc'
}

@test "add_repo_keyring_from_wget is idempotent when the keyring exists" {
    local keyring="$KEYRING_DIR/example.gpg"
    printf 'existing\n' >"$keyring"
    run add_repo_keyring_from_wget "https://example.com/key.asc" "$keyring"
    assert_success
    assert_file_contains "$keyring" "existing"
    refute_stub_call '^wget '
}

@test "add_repo_list_if_missing writes the list when it is missing" {
    local list="$LIST_DIR/example.list"
    run add_repo_list_if_missing "$list" "example.com" "deb https://example.com/ stable main"
    assert_success
    assert_file_exists "$list"
    assert_file_contains "$list" "deb https://example.com/ stable main"
    assert_stub_call '^sudo tee '
}

@test "add_repo_list_if_missing is idempotent when the pattern is present" {
    local list="$LIST_DIR/example.list"
    printf 'deb https://example.com/ stable main\n' >"$list"
    run add_repo_list_if_missing "$list" "example.com" "deb https://example.com/ other"
    assert_success
    assert_file_contains "$list" "stable main"
    run grep -F "other" "$list"
    assert_failure
    refute_stub_call '^sudo tee '
}

@test "add_repo_list_if_missing writes when the file exists but the pattern does not" {
    local list="$LIST_DIR/example.list"
    printf 'deb https://other.example/ stable main\n' >"$list"
    run add_repo_list_if_missing "$list" "example.com" "deb https://example.com/ stable main"
    assert_success
    assert_file_contains "$list" "deb https://example.com/ stable main"
}

@test "setup_repo_from_manifest_line repo kind adds a keyring and list" {
    local keyring="$KEYRING_DIR/tool.gpg"
    local list="$LIST_DIR/tool.list"
    DPKG_ARCH=amd64 LSB_CODENAME=noble
    export DPKG_ARCH LSB_CODENAME
    run setup_repo_from_manifest_line repo \
        "https://example.com/key.gpg" \
        "$keyring" \
        "$list" \
        "packages.example.com" \
        "deb [arch=ARCH] https://packages.example.com/ CODENAME main"
    assert_success
    assert_file_exists "$keyring"
    assert_file_contains "$list" "deb \[arch=amd64\] https://packages.example.com/ noble main"
}

@test "setup_repo_from_manifest_line wget kind adds a keyring and list" {
    local keyring="$KEYRING_DIR/tool.gpg"
    local list="$LIST_DIR/tool.list"
    run setup_repo_from_manifest_line wget \
        "https://example.com/key.asc" \
        "$keyring" \
        "$list" \
        "example.com" \
        "deb https://example.com/ stable main"
    assert_success
    assert_file_exists "$keyring"
    assert_file_contains "$list" "deb https://example.com/ stable main"
    assert_stub_call '^wget '
}

@test "setup_repo_from_manifest_line bruno kind calls setup_bruno_repo" {
    setup_bruno_repo() { echo "bruno-called"; }
    run setup_repo_from_manifest_line bruno
    assert_success
    assert_output "bruno-called"
}

@test "setup_repo_from_manifest_line nodesource kind calls setup_nodesource_repo" {
    setup_nodesource_repo() { echo "nodesource-called"; }
    run setup_repo_from_manifest_line nodesource
    assert_success
    assert_output "nodesource-called"
}

@test "setup_bruno_repo no-ops when bruno is already on PATH" {
    mkdir -p "$SANDBOX/bin"
    cat >"$SANDBOX/bin/bruno" <<'STUB'
#!/bin/bash
exit 0
STUB
    command chmod +x "$SANDBOX/bin/bruno"
    PATH="$SANDBOX/bin:$PATH"
    run setup_bruno_repo
    assert_success
    refute_stub_call '^curl '
    refute_stub_call '^sudo '
}

@test "setup_nodesource_repo adds the NodeSource keyring and list via helpers" {
    sudo() { echo "sudo $*" >>"$STUB_CALL_LOG"; }
    add_repo_keyring_from_curl() { echo "keyring $*" >>"$STUB_CALL_LOG"; }
    add_repo_list_if_missing() { echo "list $*" >>"$STUB_CALL_LOG"; }
    run setup_nodesource_repo
    assert_success
    assert_stub_call '^sudo mkdir -p /etc/apt/keyrings$'
    assert_stub_call 'keyring https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key /etc/apt/keyrings/nodesource.gpg'
    assert_stub_call 'list /etc/apt/sources.list.d/nodesource.list deb.nodesource.com/node_24.x'
}

@test "setup_bruno_repo adds the keyring and list when bruno is missing" {
    hide_binary bruno
    sudo() { echo "sudo $*" >>"$STUB_CALL_LOG"; }
    add_repo_list_if_missing() { echo "list $*" >>"$STUB_CALL_LOG"; }
    # Override curl|gpg so the hardcoded /etc path is never written.
    curl() { echo "curl $*" >>"$STUB_CALL_LOG"; printf 'key\n'; }
    gpg() { echo "gpg $*" >>"$STUB_CALL_LOG"; cat >/dev/null; }
    chmod() { echo "chmod $*" >>"$STUB_CALL_LOG"; }
    run setup_bruno_repo
    assert_success
    assert_stub_call 'curl .*-fsSL https://keyserver.ubuntu.com/'
    assert_stub_call 'sudo gpg --dearmor -o /etc/apt/keyrings/bruno.gpg'
    assert_stub_call 'list /etc/apt/sources.list.d/bruno.list debian.usebruno.com'
}
