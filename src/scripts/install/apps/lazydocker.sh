#!/bin/bash
# lazydocker binary from the official GitHub releases.

if ! command -v lazydocker >/dev/null 2>&1; then
    lazydocker_arch="x86_64"
    case "$(uname -m)" in
        aarch64 | arm64) lazydocker_arch="arm64" ;;
    esac
    lazydocker_release="$(curl -fsSL -o /dev/null -w '%{url_effective}' \
        https://github.com/jesseduffield/lazydocker/releases/latest || true)"
    lazydocker_version="${lazydocker_release##*/tag/}"
    lazydocker_version="${lazydocker_version#v}"
    if [[ -n "$lazydocker_version" && "$lazydocker_version" != *"https://"* ]]; then
        lazydocker_tarball="$TEMP_DIR/lazydocker.tar.gz"
        if curl -fsSL --retry 3 --retry-delay 2 \
            "https://github.com/jesseduffield/lazydocker/releases/download/v$lazydocker_version/lazydocker_${lazydocker_version}_Linux_$lazydocker_arch.tar.gz" \
            -o "$lazydocker_tarball" && [[ -s "$lazydocker_tarball" ]]; then
            sudo tar -C /usr/local/bin -xzf "$lazydocker_tarball" lazydocker
        fi
    fi
fi
