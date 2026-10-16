#!/bin/bash
# lazygit binary from the official GitHub releases.

if ! command -v lazygit >/dev/null 2>&1; then
    lazygit_arch="x86_64"
    case "$(uname -m)" in
        aarch64 | arm64) lazygit_arch="arm64" ;;
    esac
    lazygit_release="$(curl -fsSL -o /dev/null -w '%{url_effective}' \
        https://github.com/jesseduffield/lazygit/releases/latest || true)"
    lazygit_version="${lazygit_release##*/tag/}"
    lazygit_version="${lazygit_version#v}"
    if [[ -n "$lazygit_version" && "$lazygit_version" != *"https://"* ]]; then
        lazygit_tarball="$TEMP_DIR/lazygit.tar.gz"
        if curl -fsSL --retry 3 --retry-delay 2 \
            "https://github.com/jesseduffield/lazygit/releases/download/v$lazygit_version/lazygit_${lazygit_version}_Linux_$lazygit_arch.tar.gz" \
            -o "$lazygit_tarball" && [[ -s "$lazygit_tarball" ]]; then
            sudo tar -C /usr/local/bin -xzf "$lazygit_tarball" lazygit
        fi
    fi
fi
