#!/bin/bash
# fzf latest .deb from the official GitHub releases.

if ! command -v fzf >/dev/null 2>&1; then
    fzf_arch="amd64"
    case "$(uname -m)" in
        aarch64 | arm64) fzf_arch="arm64" ;;
    esac
    fzf_release="$(curl -fsSL -o /dev/null -w '%{url_effective}' \
        https://github.com/junegunn/fzf/releases/latest || true)"
    fzf_version="${fzf_release##*/tag/}"
    fzf_version="${fzf_version#v}"
    if [[ -n "$fzf_version" && "$fzf_version" != *"https://"* ]]; then
        fzf_deb="$TEMP_DIR/fzf.deb"
        if curl -fsSL --retry 3 --retry-delay 2 \
            "https://github.com/junegunn/fzf/releases/download/v$fzf_version/fzf_${fzf_version}_${fzf_arch}.deb" \
            -o "$fzf_deb" && [[ -s "$fzf_deb" ]]; then
            # apt-get (not dpkg -i) so it waits for the dpkg lock when other
            # .deb installers run in parallel.
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$fzf_deb"
        fi
    fi
fi
