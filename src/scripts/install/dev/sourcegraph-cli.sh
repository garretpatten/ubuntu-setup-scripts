#!/bin/bash

sg_binary="$TEMP_DIR/sg"
sg_url="https://sourcegraph.com/.api/src-cli/src_linux_amd64"

if ! curl -fsSL "$sg_url" -o "$sg_binary" || [[ ! -s "$sg_binary" ]]; then
    sg_url=$(curl -s https://api.github.com/repos/sourcegraph/src-cli/releases/latest | \
        grep "browser_download_url.*src_linux_amd64\"" | head -1 | cut -d '"' -f 4)
    if [[ -z "$sg_url" ]]; then
        exit 0
    fi
    curl -fsSL "$sg_url" -o "$sg_binary" || exit 0
fi

chmod +x "$sg_binary"
if ! "$sg_binary" version >/dev/null 2>&1; then
    exit 0
fi

sudo install -m 755 "$sg_binary" /usr/local/bin/sg
