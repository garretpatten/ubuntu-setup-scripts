#!/bin/bash
# Ollama via its official install script.
# A failed download/install exits non-zero so orchestrators surface the failure.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/download.sh
source "$DIR/../../lib/download.sh"

command -v ollama >/dev/null 2>&1 && exit 0

if [[ -z "${TEMP_DIR:-}" ]]; then
    echo 'ERROR: TEMP_DIR is not set; run via an orchestrator' >&2
    exit 1
fi

ollama_installer="$TEMP_DIR/ollama-install.sh"
if ! download_installer https://ollama.com/install.sh "$ollama_installer"; then
    echo 'WARNING: ollama installer download failed' >&2
    exit 1
fi
if ! bash "$ollama_installer"; then
    echo 'WARNING: ollama installer failed' >&2
    exit 1
fi
