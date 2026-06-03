#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
DOTFILES_ROOT="$PROJECT_ROOT/src/dotfiles"
vscode_settings="$HOME/.config/Code/User/settings.json"
if [[ ! -f "$vscode_settings" ]] && [[ -f "$DOTFILES_ROOT/vs-code/settings.json" ]]; then
    copy_file_safe "$DOTFILES_ROOT/vs-code/settings.json" "$vscode_settings"
fi
