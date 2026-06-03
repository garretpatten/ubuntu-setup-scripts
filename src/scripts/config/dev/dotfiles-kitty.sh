#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
DOTFILES_ROOT="$PROJECT_ROOT/src/dotfiles"
copy_directory_safe "$DOTFILES_ROOT/config/kitty" "$dest"
