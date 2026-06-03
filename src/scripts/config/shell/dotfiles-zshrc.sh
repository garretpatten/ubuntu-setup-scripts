#!/bin/bash

home="$PROJECT_ROOT/src/dotfiles/home"
[[ -f "$HOME/.tmux.conf" ]] || cp "$home/.tmux.conf" "$HOME/.tmux.conf" 2>/dev/null || true
[[ -f "$HOME/.zshrc" ]] || cp "$home/.zshrc" "$HOME/.zshrc" 2>/dev/null || true
[[ -f "$HOME/.bashrc" ]] || cp "$home/.bashrc" "$HOME/.bashrc" 2>/dev/null || true
