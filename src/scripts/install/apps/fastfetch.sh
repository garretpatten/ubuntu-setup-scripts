#!/bin/bash
# fastfetch latest .deb from the official GitHub releases.
# The zhangsongcui3371/fastfetch PPA is the primary source in all.sh; this is
# the fallback for when Launchpad is unavailable.

if ! command -v fastfetch >/dev/null 2>&1 && [[ "$(uname -m)" == "x86_64" ]]; then
    fastfetch_release="$(curl -fsSL -o /dev/null -w '%{url_effective}' \
        https://github.com/fastfetch-cli/fastfetch/releases/latest || true)"
    fastfetch_version="${fastfetch_release##*/tag/}"
    fastfetch_version="${fastfetch_version#v}"
    if [[ -n "$fastfetch_version" && "$fastfetch_version" != *"https://"* ]]; then
        fastfetch_deb="$TEMP_DIR/fastfetch.deb"
        if curl -fsSL --retry 3 --retry-delay 2 \
            "https://github.com/fastfetch-cli/fastfetch/releases/download/$fastfetch_version/fastfetch-linux-amd64.deb" \
            -o "$fastfetch_deb" && [[ -s "$fastfetch_deb" ]]; then
            # apt-get (not dpkg -i) so it waits for the dpkg lock when other
            # .deb installers run in parallel.
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$fastfetch_deb"
        fi
    fi
fi
