#!/bin/bash

tpm_dir="${HOME}/.tmux/plugins/tpm"
plugins_dir="${HOME}/.tmux/plugins"
conf="${HOME}/.config/tmux/tmux.conf"

if ! command -v git >/dev/null 2>&1; then
    echo "git unavailable; skipping tmux plugin install" >&2
    exit 0
fi

if [[ ! -f "$conf" ]]; then
    echo "tmux.conf not found at $conf; skipping tmux plugin install" >&2
    exit 0
fi

mkdir -p "$plugins_dir"
if [[ ! -x "$tpm_dir/tpm" ]]; then
    GIT_TERMINAL_PROMPT=0 git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm_dir" 2>/dev/null || true
fi
if [[ ! -x "$tpm_dir/tpm" ]]; then
    echo "failed to clone tpm to $tpm_dir" >&2
    exit 0
fi

clone_plugin() {
    local plugin="$1"
    local name="${plugin%%#*}"
    local dest="${plugins_dir}/${name##*/}"
    echo "Installing \"$name\""
    if [[ -d "$dest" ]]; then
        echo "  \"$name\" already installed"
        return 0
    fi
    GIT_TERMINAL_PROMPT=0 git clone --depth=1 --single-branch "https://github.com/${name}" "$dest" 2>/dev/null
    if [[ -d "$dest" ]]; then
        echo "  \"$name\" download success"
    else
        echo "  \"$name\" download fail" >&2
    fi
}

while IFS= read -r plugin; do
    [[ -n "$plugin" ]] || continue
    clone_plugin "$plugin"
done < <(sed -n "s/^set -g @plugin '\([^']*\)'.*/\1/p" "$conf")
