#!/bin/bash
# rustup installer.
# A failed download/install exits non-zero so orchestrators surface the failure.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/download.sh
source "$DIR/../../lib/download.sh"

[[ -f "$HOME/.cargo/env" ]] && exit 0

if [[ -z "${TEMP_DIR:-}" ]]; then
    echo 'ERROR: TEMP_DIR is not set; run via an orchestrator' >&2
    exit 1
fi

rustup_installer="$TEMP_DIR/rustup-init.sh"
if ! download_installer https://sh.rustup.rs "$rustup_installer"; then
    echo 'WARNING: rustup installer download failed' >&2
    exit 1
fi
if ! bash "$rustup_installer" -y; then
    echo 'WARNING: rustup installer failed' >&2
    exit 1
fi
