#!/bin/bash
# Neovim from the official GitHub release tarball (installs under /opt).

if ! command -v nvim >/dev/null 2>&1; then
    nvim_arch="x86_64"
    case "$(uname -m)" in
        aarch64 | arm64) nvim_arch="aarch64" ;;
    esac
    nvim_tarball="$TEMP_DIR/nvim-linux-$nvim_arch.tar.gz"
    if curl -fsSL --retry 3 --retry-delay 2 \
        "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$nvim_arch.tar.gz" \
        -o "$nvim_tarball" && [[ -s "$nvim_tarball" ]]; then
        sudo rm -rf "/opt/nvim-linux-$nvim_arch"
        sudo tar -C /opt -xzf "$nvim_tarball"
        sudo ln -sf "/opt/nvim-linux-$nvim_arch/bin/nvim" /usr/local/bin/nvim
    fi
fi
