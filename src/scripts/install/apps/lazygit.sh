#!/bin/bash
# lazygit binary from the official GitHub releases.
# A failed download exits non-zero so orchestrators surface the failure.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/download.sh
source "$DIR/../../lib/download.sh"

if command -v lazygit >/dev/null 2>&1; then
    exit 0
fi

if [[ -z "${TEMP_DIR:-}" ]]; then
    echo 'ERROR: TEMP_DIR is not set; run via an orchestrator' >&2
    exit 1
fi

lazygit_arch="x86_64"
case "$(uname -m)" in
    aarch64 | arm64) lazygit_arch="arm64" ;;
esac
if ! lazygit_tag="$(github_latest_release_tag jesseduffield/lazygit)"; then
    echo 'WARNING: could not resolve lazygit latest release' >&2
    exit 1
fi

lazygit_tarball="$TEMP_DIR/lazygit.tar.gz"
if ! download_installer \
    "https://github.com/jesseduffield/lazygit/releases/download/$lazygit_tag/lazygit_${lazygit_tag#v}_Linux_$lazygit_arch.tar.gz" \
    "$lazygit_tarball"; then
    echo 'WARNING: lazygit download failed' >&2
    exit 1
fi
sudo tar -C /usr/local/bin -xzf "$lazygit_tarball" lazygit
