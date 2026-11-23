#!/usr/bin/env bats
# Unit tests for scripts/check-shellcheck.sh.
# Runs a copy of the script inside a fixture git repo so the host repository
# is never used as the diff base.

setup() {
    load ../helpers/setup
    common_setup

    WORK="$SANDBOX/repo"
    init_git_repo "$WORK" master origin

    mkdir -p "$WORK/scripts" "$WORK/src" "$WORK/tests"
    cp "$REPO_ROOT/scripts/check-shellcheck.sh" "$WORK/scripts/check-shellcheck.sh"
    chmod +x "$WORK/scripts/check-shellcheck.sh"
    cp "$REPO_ROOT/.shellcheckrc" "$WORK/.shellcheckrc"

    # Seed origin/master with a known-clean script.
    cp "$FIXTURES_DIR/shell/clean.sh" "$WORK/src/clean.sh"
    git -C "$WORK" add src/clean.sh scripts/check-shellcheck.sh .shellcheckrc
    git -C "$WORK" commit -q -m "add clean script"
    git -C "$WORK" push -q origin master
}

teardown() {
    common_teardown
}

checkout_work_branch() {
    git -C "$WORK" checkout -q -b topic
}

@test "check-shellcheck.sh exits 0 when no shell files changed" {
    checkout_work_branch
    printf 'docs only\n' >"$WORK/README.md"
    git -C "$WORK" add README.md
    git -C "$WORK" commit -q -m "docs"
    run "$WORK/scripts/check-shellcheck.sh"
    assert_success
    assert_output --partial "No changed shell files to check (base: origin/master)"
}

@test "check-shellcheck.sh lints a changed clean script and succeeds" {
    checkout_work_branch
    printf '\necho "still ok"\n' >>"$WORK/src/clean.sh"
    git -C "$WORK" add src/clean.sh
    git -C "$WORK" commit -q -m "tweak clean script"
    run "$WORK/scripts/check-shellcheck.sh"
    assert_success
    assert_output --partial "ShellCheck -x (1 files, base: origin/master)"
    assert_output --partial "src/clean.sh"
}

@test "check-shellcheck.sh fails when a changed script is dirty" {
    checkout_work_branch
    cp "$FIXTURES_DIR/shell/dirty.sh" "$WORK/src/dirty.sh"
    git -C "$WORK" add src/dirty.sh
    git -C "$WORK" commit -q -m "add dirty script"
    run "$WORK/scripts/check-shellcheck.sh"
    assert_failure
    assert_output --partial "src/dirty.sh"
    refute_output --partial "No changed shell files"
}

@test "check-shellcheck.sh includes changed bats files" {
    checkout_work_branch
    cp "$FIXTURES_DIR/shell/clean.bats.fixture" "$WORK/tests/clean.bats"
    git -C "$WORK" add tests/clean.bats
    git -C "$WORK" commit -q -m "add clean bats"
    run "$WORK/scripts/check-shellcheck.sh"
    assert_success
    assert_output --partial "ShellCheck -x (1 files, base: origin/master)"
    assert_output --partial "tests/clean.bats"
}

@test "check-shellcheck.sh fails a dirty bats file and lists both dirty and clean paths" {
    checkout_work_branch
    cp "$FIXTURES_DIR/shell/dirty.bats.fixture" "$WORK/tests/dirty.bats"
    printf '\necho "still ok"\n' >>"$WORK/src/clean.sh"
    git -C "$WORK" add tests/dirty.bats src/clean.sh
    git -C "$WORK" commit -q -m "add dirty bats and tweak clean"
    run "$WORK/scripts/check-shellcheck.sh"
    assert_failure
    assert_output --partial "tests/dirty.bats"
    assert_output --partial "src/clean.sh"
    assert_output --partial "ShellCheck -x (2 files, base: origin/master)"
}
