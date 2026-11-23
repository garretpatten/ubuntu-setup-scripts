#!/usr/bin/env bats
# Unit tests for src/scripts/install/dev/google-mcp-server.sh.
# Ported from macOS-setup-scripts (tests/google-mcp-server.bats).
# Each @test runs in its own subshell, so per-test variable changes are intentional.
# shellcheck disable=SC2030,SC2031

setup() {
    load ../helpers/setup
    common_setup

    unset GOOGLE_MCP_DIR GOOGLE_MCP_REPO_URL GOOGLE_MCP_SYSTEM_SCRIPTS_ENV

    # shellcheck source=../../src/scripts/install/dev/google-mcp-server.sh
    source "$REAL_SCRIPTS_DIR/install/dev/google-mcp-server.sh"

    STUBS="$SANDBOX/bin"
    mkdir -p "$STUBS"
    export PATH="$STUBS:$PATH"

    install_default_stubs
}

teardown() {
    common_teardown
}

install_default_stubs() {
    cat >"$STUBS/git" <<'STUB'
#!/bin/bash
echo "git $*" >>"${STUB_CALL_LOG:?}"
if [[ "$1" == "clone" ]]; then
    dest="${*: -1}"
    mkdir -p "$dest/.git"
    printf '%s\n' 'GOOGLE_CLIENT_ID=' 'GOOGLE_CLIENT_SECRET=' 'GOOGLE_REFRESH_TOKEN=' >"$dest/.env.example"
    exit 0
fi
if [[ "$1" == "-C" && "$3" == "pull" ]]; then
    mkdir -p "$2"
    echo pulled >>"$2/.pulled"
    exit 0
fi
exit 0
STUB

    cat >"$STUBS/npm" <<'STUB'
#!/bin/bash
echo "npm $*" >>"${STUB_CALL_LOG:?}"
if [[ "$1" == "ci" ]]; then
    mkdir -p node_modules
    exit 0
fi
if [[ "$1" == "run" && "$2" == "build" ]]; then
    mkdir -p dist
    printf '%s\n' '#!/usr/bin/env node' 'console.log("stub server")' >dist/index.js
    exit 0
fi
if [[ "$1" == "run" && "$2" == "auth" ]]; then
    exit 0
fi
exit 0
STUB

    cat >"$STUBS/node" <<'STUB'
#!/bin/bash
echo "node $*" >>"${STUB_CALL_LOG:?}"
if [[ "$1" == "-p" ]]; then
    printf '%s\n' '24'
    exit 0
fi
# Pretend to be a stdio MCP server: exit 0 when stdin closes.
cat >/dev/null
exit 0
STUB

    chmod +x "$STUBS/git" "$STUBS/npm" "$STUBS/node"
}

write_dotenv() {
    local file="$1"
    shift
    mkdir -p "$(dirname "$file")"
    : >"$file"
    local pair
    for pair in "$@"; do
        printf '%s\n' "$pair" >>"$file"
    done
}

# --- sourcing ----------------------------------------------------------------

@test "sourcing google-mcp-server.sh defines functions without running the install" {
    assert_equal "$(type -t google_mcp_install)" "function"
    assert_equal "$(type -t google_mcp_clone_or_update)" "function"
    refute_stub_call '^git '
    refute_stub_call '^npm '
}

# --- clone / update ----------------------------------------------------------

@test "clone_or_update clones into ~/Projects when the checkout is missing" {
    run google_mcp_clone_or_update "$HOME/Projects/google-mcp-server"
    assert_success
    assert_dir_exists "$HOME/Projects/google-mcp-server/.git"
    assert_file_contains "$STUB_CALL_LOG" "git clone $GOOGLE_MCP_REPO_URL $HOME/Projects/google-mcp-server"
}

@test "clone_or_update fast-forwards an existing git checkout" {
    mkdir -p "$HOME/Projects/google-mcp-server/.git"
    run google_mcp_clone_or_update "$HOME/Projects/google-mcp-server"
    assert_success
    assert_file_exists "$HOME/Projects/google-mcp-server/.pulled"
    assert_file_contains "$STUB_CALL_LOG" "git -C .* pull "
    run grep -F "git clone" "$STUB_CALL_LOG"
    assert_failure
}

@test "clone_or_update logs an error when the destination is not a git checkout" {
    mkdir -p "$HOME/Projects/google-mcp-server"
    run --separate-stderr google_mcp_clone_or_update "$HOME/Projects/google-mcp-server"
    assert_failure 1
    assert_stderr --partial "google-mcp-server: $HOME/Projects/google-mcp-server exists but is not a git checkout"
}

# --- credentials -------------------------------------------------------------

@test "copy_oauth_client_credentials copies only the client id and secret" {
    write_dotenv "$HOME/Projects/system-scripts/.env" \
        'GOOGLE_CLIENT_ID="dummy-client-id"' \
        'GOOGLE_CLIENT_SECRET="dummy-client-secret"' \
        'GOOGLE_REFRESH_TOKEN="source-refresh-should-not-copy"' \
        'GITHUB_TOKEN="unrelated"'
    mkdir -p "$HOME/Projects/google-mcp-server"
    write_dotenv "$HOME/Projects/google-mcp-server/.env.example" \
        'GOOGLE_CLIENT_ID=' \
        'GOOGLE_CLIENT_SECRET=' \
        'GOOGLE_REFRESH_TOKEN='

    run google_mcp_copy_oauth_client_credentials \
        "$HOME/Projects/system-scripts/.env" \
        "$HOME/Projects/google-mcp-server/.env"
    assert_success

    assert_file_contains "$HOME/Projects/google-mcp-server/.env" 'GOOGLE_CLIENT_ID="dummy-client-id"'
    assert_file_contains "$HOME/Projects/google-mcp-server/.env" 'GOOGLE_CLIENT_SECRET="dummy-client-secret"'
    refute_output --partial "dummy-client-id"
    refute_output --partial "dummy-client-secret"
    # Refresh token comes from the example (empty), not from system-scripts.
    assert_file_contains "$HOME/Projects/google-mcp-server/.env" '^GOOGLE_REFRESH_TOKEN=$'
    run grep -F 'GITHUB_TOKEN' "$HOME/Projects/google-mcp-server/.env"
    assert_failure
    run stat -c '%a' "$HOME/Projects/google-mcp-server/.env"
    assert_output "600"
}

@test "copy_oauth_client_credentials preserves an existing refresh token" {
    write_dotenv "$HOME/Projects/system-scripts/.env" \
        'GOOGLE_CLIENT_ID=new-id' \
        'GOOGLE_CLIENT_SECRET=new-secret'
    write_dotenv "$HOME/Projects/google-mcp-server/.env" \
        'GOOGLE_CLIENT_ID=old-id' \
        'GOOGLE_CLIENT_SECRET=old-secret' \
        'GOOGLE_REFRESH_TOKEN="keep-me"'

    run google_mcp_copy_oauth_client_credentials \
        "$HOME/Projects/system-scripts/.env" \
        "$HOME/Projects/google-mcp-server/.env"
    assert_success
    assert_file_contains "$HOME/Projects/google-mcp-server/.env" '^GOOGLE_CLIENT_ID=new-id$'
    assert_file_contains "$HOME/Projects/google-mcp-server/.env" '^GOOGLE_CLIENT_SECRET=new-secret$'
    assert_file_contains "$HOME/Projects/google-mcp-server/.env" 'GOOGLE_REFRESH_TOKEN="keep-me"'
}

@test "copy_oauth_client_credentials skips a missing source without creating dest" {
    run google_mcp_copy_oauth_client_credentials \
        "$HOME/Projects/system-scripts/.env" \
        "$HOME/Projects/google-mcp-server/.env"
    assert_success
    assert_output --partial "skipped OAuth client copy"
    assert_file_not_exists "$HOME/Projects/google-mcp-server/.env"
}

@test "system_scripts_env prefers Projects, then Scripts, then the override" {
    write_dotenv "$HOME/Projects/system-scripts/.env" 'GOOGLE_CLIENT_ID=a'
    write_dotenv "$HOME/Scripts/system-scripts/.env" 'GOOGLE_CLIENT_ID=b'
    run google_mcp_system_scripts_env
    assert_success
    assert_output "$HOME/Projects/system-scripts/.env"

    rm -f "$HOME/Projects/system-scripts/.env"
    run google_mcp_system_scripts_env
    assert_success
    assert_output "$HOME/Scripts/system-scripts/.env"

    GOOGLE_MCP_SYSTEM_SCRIPTS_ENV="$SANDBOX/custom.env"
    run google_mcp_system_scripts_env
    assert_success
    assert_output "$SANDBOX/custom.env"
}

# --- build -------------------------------------------------------------------

@test "build runs npm ci and npm run build when Node is 24 or newer" {
    mkdir -p "$HOME/Projects/google-mcp-server"
    run google_mcp_build "$HOME/Projects/google-mcp-server"
    assert_success
    assert_file_exists "$HOME/Projects/google-mcp-server/dist/index.js"
    assert_file_contains "$STUB_CALL_LOG" "^npm ci$"
    assert_file_contains "$STUB_CALL_LOG" "^npm run build$"
}

@test "build skips when Node is older than 24" {
    cat >"$STUBS/node" <<'STUB'
#!/bin/bash
echo "node $*" >>"${STUB_CALL_LOG:?}"
if [[ "$1" == "-p" ]]; then
    printf '%s\n' '20'
    exit 0
fi
exit 0
STUB
    chmod +x "$STUBS/node"
    mkdir -p "$HOME/Projects/google-mcp-server"
    run google_mcp_build "$HOME/Projects/google-mcp-server"
    assert_failure 1
    assert_output --partial "Node >= 24 is required (found 20)"
    if [[ -f "$STUB_CALL_LOG" ]]; then
        run grep -F "npm ci" "$STUB_CALL_LOG"
        assert_failure
        run grep -F "npm run build" "$STUB_CALL_LOG"
        assert_failure
    fi
}

# --- auth prompt -------------------------------------------------------------

@test "prompt_auth is skipped when the session is not interactive" {
    mkdir -p "$HOME/Projects/google-mcp-server"
    run google_mcp_prompt_auth "$HOME/Projects/google-mcp-server"
    assert_success
    if [[ -f "$STUB_CALL_LOG" ]]; then
        run grep -F 'npm run auth' "$STUB_CALL_LOG"
        assert_failure
    fi
}

@test "prompt_auth runs npm run auth only when the answer is yes" {
    mkdir -p "$HOME/Projects/google-mcp-server"
    google_mcp_is_interactive() { return 0; }

    run google_mcp_prompt_auth "$HOME/Projects/google-mcp-server" <<<'n'
    assert_success
    if [[ -f "$STUB_CALL_LOG" ]]; then
        run grep -F 'npm run auth' "$STUB_CALL_LOG"
        assert_failure
    fi

    : >"$STUB_CALL_LOG"
    run google_mcp_prompt_auth "$HOME/Projects/google-mcp-server" <<<''
    assert_success
    run grep -F 'npm run auth' "$STUB_CALL_LOG"
    assert_failure

    : >"$STUB_CALL_LOG"
    run google_mcp_prompt_auth "$HOME/Projects/google-mcp-server" <<<'y'
    assert_success
    assert_file_contains "$STUB_CALL_LOG" "^npm run auth$"
}

# --- smoke check -------------------------------------------------------------

@test "smoke_check succeeds when stdin close exits 0 and credentials are set" {
    mkdir -p "$HOME/Projects/google-mcp-server/dist"
    printf '%s\n' '#!/usr/bin/env node' >"$HOME/Projects/google-mcp-server/dist/index.js"
    write_dotenv "$HOME/Projects/google-mcp-server/.env" \
        'GOOGLE_CLIENT_ID=dummy-id' \
        'GOOGLE_CLIENT_SECRET=dummy-secret' \
        'GOOGLE_REFRESH_TOKEN=dummy-refresh'
    run google_mcp_smoke_check "$HOME/Projects/google-mcp-server"
    assert_success
    assert_file_contains "$STUB_CALL_LOG" "node $HOME/Projects/google-mcp-server/dist/index.js"
}

@test "smoke_check skips starting when the refresh token is missing" {
    mkdir -p "$HOME/Projects/google-mcp-server/dist"
    printf '%s\n' '#!/usr/bin/env node' >"$HOME/Projects/google-mcp-server/dist/index.js"
    write_dotenv "$HOME/Projects/google-mcp-server/.env" \
        'GOOGLE_CLIENT_ID=dummy-id' \
        'GOOGLE_CLIENT_SECRET=dummy-secret' \
        'GOOGLE_REFRESH_TOKEN='
    run google_mcp_smoke_check "$HOME/Projects/google-mcp-server"
    assert_success
    assert_output --partial "skipped start check"
    if [[ -f "$STUB_CALL_LOG" ]]; then
        run grep -E 'node .*/dist/index.js' "$STUB_CALL_LOG"
        assert_failure
    fi
}

@test "smoke_check fails when dist/index.js is missing" {
    mkdir -p "$HOME/Projects/google-mcp-server"
    run --separate-stderr google_mcp_smoke_check "$HOME/Projects/google-mcp-server"
    assert_failure 1
    assert_stderr --partial "build output missing"
}

# --- install -----------------------------------------------------------------

@test "google_mcp_install clones, builds, copies credentials, skips auth, and smoke-checks" {
    write_dotenv "$HOME/Projects/system-scripts/.env" \
        'GOOGLE_CLIENT_ID="dummy-client-id"' \
        'GOOGLE_CLIENT_SECRET="dummy-client-secret"'
    # Leave refresh token unset so the start check is skipped in this sandbox.
    GOOGLE_MCP_DIR="$HOME/Projects/google-mcp-server"
    run google_mcp_install
    assert_success
    assert_dir_exists "$HOME/Projects/google-mcp-server/.git"
    assert_file_exists "$HOME/Projects/google-mcp-server/dist/index.js"
    assert_file_contains "$HOME/Projects/google-mcp-server/.env" 'GOOGLE_CLIENT_ID="dummy-client-id"'
    assert_output --partial "skipped start check"
    if [[ -f "$STUB_CALL_LOG" ]]; then
        run grep -F 'npm run auth' "$STUB_CALL_LOG"
        assert_failure
    fi
}
