#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
dotfiles_home_root="$PROJECT_ROOT/src/dotfiles/home"
copy_file_safe "$dotfiles_home_root/.tmux.conf" "$HOME/.tmux.conf"
copy_file_safe "$dotfiles_home_root/.zshrc" "$HOME/.zshrc"
copy_file_safe "$dotfiles_home_root/.bashrc" "$HOME/.bashrc"
