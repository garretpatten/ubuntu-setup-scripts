#!/bin/bash

if command -v balena-etcher >/dev/null 2>&1; then
    exit 0
fi
if dpkg -s balena-etcher >/dev/null 2>&1; then
    exit 0
fi

etcher_deb="$TEMP_DIR/balena-etcher.deb"
etcher_tag=$(curl -fsSL https://api.github.com/repos/balena-io/etcher/releases/latest 2>/dev/null | \
    grep '"tag_name"' | head -1 | cut -d '"' -f 4)
etcher_tag="${etcher_tag:-v2.1.6}"
etcher_version="${etcher_tag#v}"
etcher_url="https://github.com/balena-io/etcher/releases/download/${etcher_tag}/balena-etcher_${etcher_version}_amd64.deb"

curl -fsSL --retry 3 --retry-delay 2 "$etcher_url" -o "$etcher_deb" || exit 0
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$etcher_deb" || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y --no-install-recommends || true
