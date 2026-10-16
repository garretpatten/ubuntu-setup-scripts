#!/bin/bash
# Ghostty terminal from the ghostty-ubuntu project's release .deb.
# Resolves the latest release via the releases/latest redirect and the
# expanded_assets page; the GitHub API is rate-limited on shared CI runners.

if command -v ghostty >/dev/null 2>&1; then
    exit 0
fi

ghostty_os_version="$(. /etc/os-release && printf '%s' "$VERSION_ID")"
case "$ghostty_os_version" in
    24.04 | 26.04) ;;
    *) exit 0 ;;
esac
ghostty_arch="$(dpkg --print-architecture)"

ghostty_tag="$(curl -fsSL -o /dev/null -w '%{url_effective}' \
    https://github.com/mkasberg/ghostty-ubuntu/releases/latest || true)"
ghostty_tag="${ghostty_tag##*/tag/}"
case "$ghostty_tag" in
    "" | *"https://"*) exit 1 ;;
esac

ghostty_deb_path="$(curl -fsSL \
    "https://github.com/mkasberg/ghostty-ubuntu/releases/expanded_assets/$ghostty_tag" \
    | grep -oE "/mkasberg/ghostty-ubuntu/releases/download/[^\" ]+_${ghostty_arch}_${ghostty_os_version}\.deb" \
    | head -1)"
if [[ -z "$ghostty_deb_path" ]]; then
    exit 1
fi

ghostty_deb="$TEMP_DIR/ghostty.deb"
if curl -fsSL --retry 3 --retry-delay 2 \
    "https://github.com$ghostty_deb_path" -o "$ghostty_deb" && [[ -s "$ghostty_deb" ]]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$ghostty_deb" || exit 1
fi
