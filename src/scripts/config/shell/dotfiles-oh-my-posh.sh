#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
dotfiles_root="$PROJECT_ROOT/src/dotfiles"
copy_directory_safe "$dotfiles_root/config/oh-my-posh" "$HOME/.config/oh-my-posh"
