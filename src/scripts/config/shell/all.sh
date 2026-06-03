#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../utils.sh
source "$DIR/../../utils.sh"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/dotfiles-ghostty.sh"
run_script "$DIR/dotfiles-oh-my-posh.sh"
run_script "$DIR/dotfiles-tmux.sh"
run_script "$DIR/dotfiles-zshrc.sh"
run_script "$DIR/dotfiles-path.sh"
run_script "$DIR/chsh-zsh.sh"
