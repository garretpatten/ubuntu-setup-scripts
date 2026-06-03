#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
dotfiles_root="$PROJECT_ROOT/src/dotfiles"
dotfiles_home_root="$dotfiles_root/home"
if [[ -d "$dotfiles_home_root/zsh" ]]; then
    if [[ ! -f "$HOME/.dotfiles_path" ]]; then
        printf '%s\n' "$dotfiles_root" >"$HOME/.dotfiles_path" 2>>"$ERROR_LOG_FILE" || true
    else
        existing_root=""
        IFS= read -r existing_root <"$HOME/.dotfiles_path" || true
        if [[ -z "$existing_root" ]] || [[ ! -d "$existing_root/home/zsh" ]]; then
            printf '%s\n' "$dotfiles_root" >"$HOME/.dotfiles_path" 2>>"$ERROR_LOG_FILE" || true
        fi
    fi
fi
