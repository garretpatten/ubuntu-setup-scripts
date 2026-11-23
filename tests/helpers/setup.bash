#!/bin/bash
# Shared setup for the bats unit tests. Load with: load helpers/setup
# or, from a nested suite: load ../helpers/setup

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$TESTS_DIR/.." && pwd)"
FIXTURES_DIR="$TESTS_DIR/fixtures"
REAL_SCRIPTS_DIR="$REPO_ROOT/src/scripts"
# Snapshot the real home before tests redirect HOME into the sandbox.
REAL_HOME="${HOME}"
export TESTS_DIR REPO_ROOT FIXTURES_DIR REAL_SCRIPTS_DIR

# bats-support, bats-assert and bats-file live in different places depending on
# how they were installed (bats-action, scripts/install-bats.sh, ~/.local).
BATS_LIB_PATH="${BATS_LIB_PATH:+$BATS_LIB_PATH:}${REPO_ROOT}/.tools:/usr/lib:/usr/local/lib:/usr/lib/bats:/opt/homebrew/lib:${REAL_HOME}/.local/lib"
export BATS_LIB_PATH

common_setup() {
    # run --separate-stderr needs bats >= 1.5.0.
    bats_require_minimum_version 1.5.0
    bats_load_library bats-support
    bats_load_library bats-assert
    bats_load_library bats-file

    SANDBOX="$(mktemp -d "${BATS_TMPDIR:-/tmp}/ubuntu-setup-tests.XXXXXX")"
    export SANDBOX
    export HOME="$SANDBOX/home"
    mkdir -p "$HOME"

    # Isolated git config so fixture repos do not use host signing settings.
    export GIT_CONFIG_GLOBAL="$SANDBOX/gitconfig"
    export GIT_CONFIG_SYSTEM=/dev/null
    git config --file "$GIT_CONFIG_GLOBAL" user.email "test@example.com"
    git config --file "$GIT_CONFIG_GLOBAL" user.name "Test"
    git config --file "$GIT_CONFIG_GLOBAL" commit.gpgsign false
    git config --file "$GIT_CONFIG_GLOBAL" tag.gpgsign false
    git config --file "$GIT_CONFIG_GLOBAL" init.defaultBranch master

    export PROJECT_ROOT="$SANDBOX/project"
    export TEMP_DIR="$SANDBOX/tmp"
    mkdir -p "$PROJECT_ROOT" "$TEMP_DIR"

    # Fake binaries shadow the real ones so tests never touch apt, snap, or the network.
    export PATH="$TESTS_DIR/stubs:$PATH"
    export STUB_CALL_LOG="$SANDBOX/stub-calls.log"
    : >"$STUB_CALL_LOG"
    unset CURL_STUB_MODE CURL_STUB_BODY CURL_STUB_REDIRECT \
        WGET_STUB_MODE WGET_STUB_BODY \
        APT_GET_FAIL APT_GET_FAIL_PACKAGE \
        SNAP_LIST SNAP_INSTALL_RC SNAP_INSTALL_FAIL_TIMES \
        SYSTEMCTL_FAIL TIMEOUT_STUB_RC \
        ADD_APT_REPOSITORY_FAIL DPKG_ARCH LSB_CODENAME \
        HIDDEN_BINARIES
}

common_teardown() {
    if [[ -n "${SANDBOX:-}" && -d "$SANDBOX" ]]; then
        rm -rf "$SANDBOX"
    fi
}

# Print the recorded stub calls (one per line).
stub_calls() {
    cat "$STUB_CALL_LOG"
}

# Assert some recorded stub call matches the given extended regex.
assert_stub_call() {
    if ! grep -Eq -- "$1" "$STUB_CALL_LOG"; then
        fail "no stub call matching '$1':"$'\n'"$(stub_calls)"
    fi
}

# Assert no recorded stub call matches the given extended regex.
refute_stub_call() {
    if grep -Eq -- "$1" "$STUB_CALL_LOG"; then
        fail "unexpected stub call matching '$1':"$'\n'"$(stub_calls)"
    fi
}

# Make `command -v NAME` fail without dropping directories like /usr/bin
# from PATH (those also hold rm, cat, and grep).
hide_binary() {
    local name="$1"
    HIDDEN_BINARIES="${HIDDEN_BINARIES:+$HIDDEN_BINARIES }$name"
    export HIDDEN_BINARIES
    # Invoked as command -v via hide_binary callers and sourced libs.
    # shellcheck disable=SC2329
    command() {
        if [[ "$1" == "-v" && $# -ge 2 ]]; then
            local hidden
            # shellcheck disable=SC2086
            for hidden in ${HIDDEN_BINARIES:-}; do
                if [[ "$2" == "$hidden" ]]; then
                    return 1
                fi
            done
        fi
        builtin command "$@"
    }
}

# Create a git repo at $1 with two commits. Optional $2 is the branch name
# (default: master). If $3 is "origin", add a local bare remote and fetch it
# so refs/remotes/origin/<branch> exists.
init_git_repo() {
    local work="$1"
    local branch="${2:-master}"
    local with_origin="${3:-}"
    mkdir -p "$work"
    git init -q "$work"
    printf 'first\n' >"$work/README"
    git -C "$work" add README
    git -C "$work" commit -q -m "first"
    git -C "$work" branch -q -M "$branch"
    printf 'second\n' >"$work/README"
    git -C "$work" add README
    git -C "$work" commit -q -m "second"

    if [[ "${with_origin}" == "origin" ]]; then
        local bare="${work}.git"
        git clone -q --bare "$work" "$bare"
        git -C "$work" remote add origin "$bare"
        git -C "$work" fetch -q origin
    fi
}

