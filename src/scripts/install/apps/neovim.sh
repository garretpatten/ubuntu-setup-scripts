#!/bin/bash
# Neovim from the official GitHub release tarball (installs under /opt).
# A failed download exits non-zero so orchestrators surface the failure.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/download.sh
source "$DIR/../../lib/download.sh"

if command -v nvim >/dev/null 2>&1; then
    exit 0
fi

if [[ -z "${TEMP_DIR:-}" ]]; then
    echo 'ERROR: TEMP_DIR is not set; run via an orchestrator' >&2
    exit 1
fi

nvim_arch="x86_64"
case "$(uname -m)" in
    aarch64 | arm64) nvim_arch="aarch64" ;;
esac
nvim_tarball="$TEMP_DIR/nvim-linux-$nvim_arch.tar.gz"
if ! download_installer \
    "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$nvim_arch.tar.gz" \
    "$nvim_tarball"; then
    echo 'WARNING: neovim download failed' >&2
    exit 1
fi

sudo rm -rf "/opt/nvim-linux-$nvim_arch"
sudo tar -C /opt -xzf "$nvim_tarball"
sudo ln -sf "/opt/nvim-linux-$nvim_arch/bin/nvim" /usr/local/bin/nvim
