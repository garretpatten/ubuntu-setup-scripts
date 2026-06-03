#!/bin/bash

# Avoid login hangs when pass-cli is in .zshrc but Proton Pass is not ready yet.

ensure_zshrc_login_safe() {
    local zshrc="$HOME/.zshrc"
    [[ -f "$zshrc" ]] || return 0
    grep -qE '^GITHUB_TOKEN=\$\(pass-cli item view' "$zshrc" 2>/dev/null || return 0
    sed -i.bak-setup-scripts \
        -e '/pass-cli item view/s/^/# disabled-by-setup-scripts: /' \
        -e '/^export GITHUB_TOKEN$/s/^/# disabled-by-setup-scripts: /' \
        "$zshrc" || true
}

zsh_login_safe() {
    local zsh_path="$1"
    if [[ -z "$zsh_path" ]] || [[ ! -x "$zsh_path" ]]; then
        return 1
    fi
    ensure_zshrc_login_safe
    if command -v timeout >/dev/null 2>&1; then
        timeout 5 "$zsh_path" -ic 'exit 0' >/dev/null 2>&1
    else
        "$zsh_path" -fc 'exit 0' >/dev/null 2>&1
    fi
}
