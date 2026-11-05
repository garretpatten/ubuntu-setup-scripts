#!/bin/bash
# oh-my-posh prompt theme engine via its official install script.
# A failed download/install exits non-zero so orchestrators surface the failure.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/download.sh
source "$DIR/../../lib/download.sh"

if command -v oh-my-posh >/dev/null 2>&1; then
    exit 0
fi

if [[ -z "${TEMP_DIR:-}" ]]; then
    echo 'ERROR: TEMP_DIR is not set; run via an orchestrator' >&2
    exit 1
fi

install_dir="${HOME}/.local/bin"
install_script="$TEMP_DIR/oh-my-posh-install.sh"
mkdir -p "$install_dir"
if ! download_installer https://ohmyposh.dev/install.sh "$install_script"; then
    echo 'WARNING: oh-my-posh installer download failed' >&2
    exit 1
fi
if ! bash "$install_script" -d "$install_dir"; then
    echo 'WARNING: oh-my-posh installer failed' >&2
    exit 1
fi
