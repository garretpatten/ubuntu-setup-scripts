#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/dotfiles-nvim.sh"
run_script "$DIR/dotfiles-fastfetch.sh"
run_script "$DIR/dotfiles-btop.sh"
run_script "$DIR/dotfiles-alacritty.sh"
run_script "$DIR/dotfiles-kitty.sh"
run_script "$DIR/dotfiles-zellij.sh"
run_script "$DIR/dotfiles-vimrc.sh"
run_script "$DIR/vscode-settings.sh"
run_script "$DIR/gitconfig.sh"
