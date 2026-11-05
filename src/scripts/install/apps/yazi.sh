#!/bin/bash
# yazi file manager and ya companion binaries from the official GitHub releases.
# A failed download exits non-zero so orchestrators surface the failure.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/download.sh
source "$DIR/../../lib/download.sh"

if command -v yazi >/dev/null 2>&1; then
    exit 0
fi

if [[ -z "${TEMP_DIR:-}" ]]; then
    echo 'ERROR: TEMP_DIR is not set; run via an orchestrator' >&2
    exit 1
fi

yazi_arch="x86_64-unknown-linux-gnu"
case "$(uname -m)" in
    aarch64 | arm64) yazi_arch="aarch64-unknown-linux-gnu" ;;
esac
yazi_zip="$TEMP_DIR/yazi.zip"
if ! download_installer \
    "https://github.com/sxyazi/yazi/releases/latest/download/yazi-$yazi_arch.zip" \
    "$yazi_zip"; then
    echo 'WARNING: yazi download failed' >&2
    exit 1
fi

unzip -q -o "$yazi_zip" "yazi-$yazi_arch/yazi" "yazi-$yazi_arch/ya" -d "$TEMP_DIR"
sudo install -m 755 "$TEMP_DIR/yazi-$yazi_arch/yazi" /usr/local/bin/yazi
sudo install -m 755 "$TEMP_DIR/yazi-$yazi_arch/ya" /usr/local/bin/ya
