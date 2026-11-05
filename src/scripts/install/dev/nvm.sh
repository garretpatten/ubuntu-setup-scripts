#!/bin/bash
# nvm via its pinned install script.
# A failed download/install exits non-zero so orchestrators surface the failure.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/download.sh
source "$DIR/../../lib/download.sh"

[[ -d "$HOME/.nvm" ]] && exit 0

if [[ -z "${TEMP_DIR:-}" ]]; then
    echo 'ERROR: TEMP_DIR is not set; run via an orchestrator' >&2
    exit 1
fi

nvm_installer="$TEMP_DIR/nvm-install.sh"
if ! download_installer \
    https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh \
    "$nvm_installer"; then
    echo 'WARNING: nvm installer download failed' >&2
    exit 1
fi
if ! bash "$nvm_installer"; then
    echo 'WARNING: nvm installer failed' >&2
    exit 1
fi
