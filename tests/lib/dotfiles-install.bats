#!/usr/bin/env bats
# Unit tests for src/scripts/lib/dotfiles-install.sh.

setup() {
    load ../helpers/setup
    common_setup
    # shellcheck source=../../src/scripts/lib/dotfiles-install.sh
    source "$REAL_SCRIPTS_DIR/lib/dotfiles-install.sh"

    PROJECT_ROOT="$SANDBOX/project"
    export PROJECT_ROOT
    mkdir -p "$PROJECT_ROOT/src/dotfiles"
    cp -a "$FIXTURES_DIR/dotfiles/." "$PROJECT_ROOT/src/dotfiles/"
    XDG_CONFIG_HOME="$HOME/.config"
    export XDG_CONFIG_HOME
}

teardown() {
    common_teardown
}

@test "expand_home_path leaves a non-tilde path unchanged" {
    run expand_home_path "/tmp/example"
    assert_success
    assert_output "/tmp/example"
}

@test "expand_home_path expands a lone tilde to HOME" {
    run expand_home_path "~"
    assert_success
    assert_output "$HOME"
}

@test "expand_home_path expands ~/relative to HOME" {
    # Literal tilde path: expand_home_path must expand it, not the shell.
    # shellcheck disable=SC2088
    run expand_home_path "~/.gitconfig"
    assert_success
    assert_output "$HOME/.gitconfig"
}

@test "expand_home_path does not expand ~user paths" {
    run expand_home_path "~someone/file"
    assert_success
    assert_output "~someone/file"
}

@test "copy_dotfile_file copies when the destination is missing" {
    run copy_dotfile_file git/gitconfig ~/.gitconfig
    assert_success
    assert_file_exists "$HOME/.gitconfig"
    assert_file_contains "$HOME/.gitconfig" "name = Test"
}

@test "copy_dotfile_file is idempotent and does not overwrite" {
    mkdir -p "$HOME"
    printf 'existing\n' >"$HOME/.gitconfig"
    run copy_dotfile_file git/gitconfig ~/.gitconfig
    assert_success
    assert_file_contains "$HOME/.gitconfig" "existing"
    run grep -F "name = Test" "$HOME/.gitconfig"
    assert_failure
}

@test "link_dotfiles_xdg_config_dirs no-ops when the config tree is missing" {
    rm -rf "$PROJECT_ROOT/src/dotfiles/config"
    run link_dotfiles_xdg_config_dirs
    assert_success
    assert_dir_not_exists "$XDG_CONFIG_HOME/btop"
}

@test "link_dotfiles_xdg_config_dirs symlinks each config app directory" {
    run link_dotfiles_xdg_config_dirs
    assert_success
    assert_link_exists "$XDG_CONFIG_HOME/btop"
    assert_link_exists "$XDG_CONFIG_HOME/ghostty"
    assert_file_exists "$XDG_CONFIG_HOME/btop/btop.conf"
    src_btop="$(cd "$PROJECT_ROOT/src/dotfiles/config/btop" && pwd)"
    assert_equal "$(readlink "$XDG_CONFIG_HOME/btop")" "$src_btop"
}

@test "link_dotfiles_xdg_config_dirs backs up an existing directory then symlinks" {
    mkdir -p "$XDG_CONFIG_HOME/btop"
    printf 'mine\n' >"$XDG_CONFIG_HOME/btop/btop.conf"
    run --separate-stderr link_dotfiles_xdg_config_dirs
    assert_success
    assert_link_exists "$XDG_CONFIG_HOME/btop"
    assert_file_contains "$XDG_CONFIG_HOME/btop/btop.conf" "theme = default"
    bak="$(find "$XDG_CONFIG_HOME" -maxdepth 1 -type d -name 'btop.dotfiles-bak-*')"
    assert [ -n "$bak" ]
    assert_file_contains "$bak/btop.conf" "mine"
}

@test "link_dotfiles_xdg_config_dirs skips a symlink that already points at the source" {
    src_btop="$(cd "$PROJECT_ROOT/src/dotfiles/config/btop" && pwd)"
    mkdir -p "$XDG_CONFIG_HOME"
    ln -s "$src_btop" "$XDG_CONFIG_HOME/btop"
    run link_dotfiles_xdg_config_dirs
    assert_success
    assert_equal "$(readlink "$XDG_CONFIG_HOME/btop")" "$src_btop"
}

@test "install_dotfiles_from_manifest copies file entries and skips comments" {
    run install_dotfiles_from_manifest "$FIXTURES_DIR/dotfiles.manifest"
    assert_success
    assert_file_exists "$HOME/.gitconfig"
    assert_file_exists "$HOME/.zshrc"
    assert_file_contains "$HOME/.zshrc" "zshrc fixture"
}
