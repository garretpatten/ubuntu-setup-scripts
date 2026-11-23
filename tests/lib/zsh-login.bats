#!/usr/bin/env bats
# Unit tests for src/scripts/lib/zsh-login.sh.

setup() {
    load ../helpers/setup
    common_setup
    # shellcheck source=../../src/scripts/lib/zsh-login.sh
    source "$REAL_SCRIPTS_DIR/lib/zsh-login.sh"
}

teardown() {
    common_teardown
}

@test "ensure_zshrc_login_safe no-ops when ~/.zshrc is missing" {
    run ensure_zshrc_login_safe
    assert_success
    assert_file_not_exists "$HOME/.zshrc"
}

@test "ensure_zshrc_login_safe no-ops when there is no pass-cli line" {
    printf 'export EDITOR=vim\n' >"$HOME/.zshrc"
    run ensure_zshrc_login_safe
    assert_success
    assert_file_contains "$HOME/.zshrc" "export EDITOR=vim"
    run grep -F "disabled-by-setup-scripts" "$HOME/.zshrc"
    assert_failure
}

@test "ensure_zshrc_login_safe comments out pass-cli token lines" {
    cat >"$HOME/.zshrc" <<'ZSHRC'
# keep this
GITHUB_TOKEN=$(pass-cli item view --field password GitHub)
export GITHUB_TOKEN
ZSHRC
    run ensure_zshrc_login_safe
    assert_success
    assert_file_contains "$HOME/.zshrc" "# disabled-by-setup-scripts: GITHUB_TOKEN=\$(pass-cli item view"
    assert_file_contains "$HOME/.zshrc" "# disabled-by-setup-scripts: export GITHUB_TOKEN"
    assert_file_contains "$HOME/.zshrc" "# keep this"
    assert_file_exists "$HOME/.zshrc.bak-setup-scripts"
}

@test "zsh_login_safe returns 1 when zsh is missing or not executable" {
    run zsh_login_safe ""
    assert_failure 1
    run zsh_login_safe "$SANDBOX/no-such-zsh"
    assert_failure 1
}

@test "zsh_login_safe uses timeout when it is available" {
    mkdir -p "$SANDBOX/bin"
    cat >"$SANDBOX/bin/zsh" <<'STUB'
#!/bin/bash
echo "zsh $*" >>"${STUB_CALL_LOG:?}"
exit 0
STUB
    chmod +x "$SANDBOX/bin/zsh"
    run zsh_login_safe "$SANDBOX/bin/zsh"
    assert_success
    assert_stub_call "timeout 5 $SANDBOX/bin/zsh -ic exit 0"
}

@test "zsh_login_safe falls back to zsh -fc when timeout is missing" {
    mkdir -p "$SANDBOX/bin"
    cat >"$SANDBOX/bin/zsh" <<'STUB'
#!/bin/bash
echo "zsh $*" >>"${STUB_CALL_LOG:?}"
exit 0
STUB
    chmod +x "$SANDBOX/bin/zsh"
    hide_binary timeout
    run zsh_login_safe "$SANDBOX/bin/zsh"
    assert_success
    assert_stub_call "zsh -fc exit 0"
    refute_stub_call '^timeout '
}
