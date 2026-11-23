#!/usr/bin/env bats
# Unit tests for src/scripts/lib/git-submodules.sh.

setup() {
    load ../helpers/setup
    common_setup
    # shellcheck source=../../src/scripts/lib/git-submodules.sh
    source "$REAL_SCRIPTS_DIR/lib/git-submodules.sh"

    # Per-test git stub in $SANDBOX/bin so fixture repo helpers can still use
    # the real git from PATH during setup.
    GIT_BIN="$SANDBOX/bin"
    mkdir -p "$GIT_BIN"
}

teardown() {
    common_teardown
}

install_git_stub() {
    local status_output="$1"
    cat >"$GIT_BIN/git" <<STUB
#!/bin/bash
echo "git \$*" >>"\${STUB_CALL_LOG:?}"
if [[ "\$1" == "submodule" && "\$2" == "status" ]]; then
    printf '%s\\n' '$status_output'
    exit 0
fi
exit 0
STUB
    chmod +x "$GIT_BIN/git"
    PATH="$GIT_BIN:$PATH"
}

@test "ensure_submodules_synced errors when project_root is unset" {
    unset PROJECT_ROOT
    run --separate-stderr ensure_submodules_synced ""
    assert_failure 1
    assert_stderr --partial "ERROR: PROJECT_ROOT is not set"
}

@test "ensure_submodules_synced skips when the path is not a git repository" {
    mkdir -p "$PROJECT_ROOT"
    run --separate-stderr ensure_submodules_synced "$PROJECT_ROOT"
    assert_success
    assert_stderr --partial "WARNING: Not a git repository"
}

@test "ensure_submodules_synced initializes uninitialized submodules" {
    mkdir -p "$PROJECT_ROOT/.git"
    install_git_stub "-abc123 src/dotfiles"
    run ensure_submodules_synced "$PROJECT_ROOT"
    assert_success
    assert_output --partial "Initializing submodules"
    assert_stub_call 'git submodule update --init --recursive'
}

@test "ensure_submodules_synced updates already-initialized submodules" {
    mkdir -p "$PROJECT_ROOT/.git"
    install_git_stub " abc123 src/dotfiles (v1.0)"
    run ensure_submodules_synced "$PROJECT_ROOT"
    assert_success
    assert_output --partial "Updating submodules"
    assert_stub_call 'git submodule update --recursive'
    refute_stub_call 'git submodule update --init'
}
