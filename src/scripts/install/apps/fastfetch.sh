#!/bin/bash
# fastfetch latest .deb from the official GitHub releases.
# The zhangsongcui3371/fastfetch PPA is the primary source in all.sh; this is
# the fallback for when Launchpad is unavailable.
# A failed fallback download exits non-zero so orchestrators surface it.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/download.sh
source "$DIR/../../lib/download.sh"

if command -v fastfetch >/dev/null 2>&1; then
    exit 0
fi
if [[ "$(uname -m)" != "x86_64" ]]; then
    exit 0
fi

if ! fastfetch_tag="$(github_latest_release_tag fastfetch-cli/fastfetch)"; then
    echo 'WARNING: could not resolve fastfetch latest release' >&2
    exit 1
fi

fastfetch_deb="$TEMP_DIR/fastfetch.deb"
if ! download_installer \
    "https://github.com/fastfetch-cli/fastfetch/releases/download/$fastfetch_tag/fastfetch-linux-amd64.deb" \
    "$fastfetch_deb"; then
    echo 'WARNING: fastfetch deb download failed' >&2
    exit 1
fi

# apt-get (not dpkg -i) so it waits for the dpkg lock when other
# .deb installers run in parallel.
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$fastfetch_deb"
