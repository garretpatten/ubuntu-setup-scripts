#!/bin/bash
# Cursor Agent CLI via its official install script.
# A failed download/install exits non-zero so orchestrators surface the failure.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/download.sh
source "$DIR/../../lib/download.sh"

command -v cursor-agent >/dev/null 2>&1 && exit 0

if [[ -z "${TEMP_DIR:-}" ]]; then
    echo 'ERROR: TEMP_DIR is not set; run via an orchestrator' >&2
    exit 1
fi

cursor_installer="$TEMP_DIR/cursor-install.sh"
if ! download_installer https://cursor.com/install "$cursor_installer"; then
    echo 'WARNING: cursor installer download failed' >&2
    exit 1
fi
if ! bash "$cursor_installer"; then
    echo 'WARNING: cursor installer failed' >&2
    exit 1
fi
