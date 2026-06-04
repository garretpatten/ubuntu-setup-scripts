#!/bin/bash

# shellcheck source=../../lib/zsh-login.sh
source "$(dirname "$0")/../../lib/zsh-login.sh"
ensure_zshrc_login_safe
zsh_path="$(command -v zsh 2>/dev/null || true)"
if [[ -n "$zsh_path" && "$SHELL" != "$zsh_path" ]] && zsh_login_safe "$zsh_path"; then
    chsh -s "$zsh_path" 2>/dev/null || true
fi
