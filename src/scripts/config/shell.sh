#!/bin/bash

# Shell dotfiles and terminal configs from the submodule (~/.dotfiles_path, tmux modular tree).

# shellcheck source=../utils.sh
source "$(dirname "$0")/../utils.sh"

dotfiles_root="$PROJECT_ROOT/src/dotfiles"
dotfiles_home_root="$dotfiles_root/home"

if [[ -d "$dotfiles_root/config" ]]; then
    copy_directory_safe "$dotfiles_root/config/ghostty" "$HOME/.config/ghostty"
    copy_directory_safe "$dotfiles_root/config/oh-my-posh" "$HOME/.config/oh-my-posh"
    # home/.tmux.conf sources ~/.config/tmux/includes/base.conf — see submodule README.
    copy_directory_safe "$dotfiles_root/config/tmux" "$HOME/.config/tmux"
fi

if [[ -d "$dotfiles_home_root" ]]; then
    copy_file_safe "$dotfiles_home_root/.tmux.conf" "$HOME/.tmux.conf"
    copy_file_safe "$dotfiles_home_root/.zshrc" "$HOME/.zshrc"
    copy_file_safe "$dotfiles_home_root/.bashrc" "$HOME/.bashrc"
fi

ensure_zshrc_login_safe

# ~./dotfiles_path: cache checkout so home/.zshrc can source home/zsh/ubuntu.zsh.
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

zsh_path="$(command -v zsh 2>/dev/null || true)"
if [[ -n "$zsh_path" && "$SHELL" != "$zsh_path" ]] && zsh_login_safe "$zsh_path"; then
    chsh -s "$zsh_path" 2>/dev/null || true
fi
