#!/bin/bash

home="$PROJECT_ROOT/src/dotfiles/home"
if [[ ! -f "$HOME/.tmux.conf" ]]; then
    cp "$home/.tmux.conf" "$HOME/.tmux.conf" 2>/dev/null || true
fi
if [[ ! -f "$HOME/.zshrc" ]]; then
    cp "$home/.zshrc" "$HOME/.zshrc" 2>/dev/null || true
fi
if [[ ! -f "$HOME/.bashrc" ]]; then
    cp "$home/.bashrc" "$HOME/.bashrc" 2>/dev/null || true
fi
