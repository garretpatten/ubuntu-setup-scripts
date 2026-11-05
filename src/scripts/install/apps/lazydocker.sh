#!/bin/bash
# lazydocker binary from the official GitHub releases.
# A failed download exits non-zero so orchestrators surface the failure.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/download.sh
source "$DIR/../../lib/download.sh"

if command -v lazydocker >/dev/null 2>&1; then
    exit 0
fi

if [[ -z "${TEMP_DIR:-}" ]]; then
    echo 'ERROR: TEMP_DIR is not set; run via an orchestrator' >&2
    exit 1
fi

lazydocker_arch="x86_64"
case "$(uname -m)" in
    aarch64 | arm64) lazydocker_arch="arm64" ;;
esac
if ! lazydocker_tag="$(github_latest_release_tag jesseduffield/lazydocker)"; then
    echo 'WARNING: could not resolve lazydocker latest release' >&2
    exit 1
fi

lazydocker_tarball="$TEMP_DIR/lazydocker.tar.gz"
if ! download_installer \
    "https://github.com/jesseduffield/lazydocker/releases/download/$lazydocker_tag/lazydocker_${lazydocker_tag#v}_Linux_$lazydocker_arch.tar.gz" \
    "$lazydocker_tarball"; then
    echo 'WARNING: lazydocker download failed' >&2
    exit 1
fi
sudo tar -C /usr/local/bin -xzf "$lazydocker_tarball" lazydocker
