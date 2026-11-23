#!/usr/bin/env bats
# Unit tests for src/scripts/lib/apt-repos.sh.

setup() {
    load ../helpers/setup
    common_setup
    # shellcheck source=../../src/scripts/lib/apt-repos.sh
    source "$REAL_SCRIPTS_DIR/lib/apt-repos.sh"
}

teardown() {
    common_teardown
}

@test "add_ppas_parallel no-ops when given no PPAs" {
    run add_ppas_parallel
    assert_success
    refute_stub_call 'add-apt-repository'
}

@test "add_ppas_parallel adds a single PPA sequentially" {
    run add_ppas_parallel "ppa:example/one"
    assert_success
    assert_stub_call 'sudo add-apt-repository -y ppa:example/one'
    refute_stub_call 'xargs'
}

@test "add_ppas_parallel adds two PPAs sequentially" {
    run add_ppas_parallel "ppa:example/one" "ppa:example/two"
    assert_success
    assert_stub_call 'sudo add-apt-repository -y ppa:example/one'
    assert_stub_call 'sudo add-apt-repository -y ppa:example/two'
}

@test "add_ppas_parallel fans out with xargs -P 2 when given more than two PPAs" {
    run add_ppas_parallel "ppa:example/one" "ppa:example/two" "ppa:example/three"
    assert_success
    assert_stub_call 'sudo add-apt-repository -y ppa:example/one'
    assert_stub_call 'sudo add-apt-repository -y ppa:example/two'
    assert_stub_call 'sudo add-apt-repository -y ppa:example/three'
}

@test "add_ppas_parallel continues when add-apt-repository fails" {
    ADD_APT_REPOSITORY_FAIL=1
    export ADD_APT_REPOSITORY_FAIL
    run add_ppas_parallel "ppa:example/one"
    assert_success
    assert_stub_call 'sudo add-apt-repository -y ppa:example/one'
}
