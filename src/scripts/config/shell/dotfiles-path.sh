#!/bin/bash

root="$PROJECT_ROOT/src/dotfiles"
[[ -d "$root/home/zsh" ]] || exit 0
if [[ ! -f "$HOME/.dotfiles_path" ]]; then
    printf '%s\n' "$root" >"$HOME/.dotfiles_path"
else
    existing=$(head -1 "$HOME/.dotfiles_path" 2>/dev/null || true)
    if [[ -z "$existing" ]] || [[ ! -d "$existing/home/zsh" ]]; then
        printf '%s\n' "$root" >"$HOME/.dotfiles_path"
    fi
fi
