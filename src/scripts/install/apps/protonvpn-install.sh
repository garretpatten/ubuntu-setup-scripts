#!/bin/bash

protonvpn_deb="${TEMP_DIR:-/tmp}/protonvpn-stable-release.deb"
protonvpn_release_url="https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.10_all.deb"

if dpkg -s proton-vpn-gnome-desktop >/dev/null 2>&1; then
    exit 0
fi

if [[ ! -f "$protonvpn_deb" ]]; then
    curl -fsSL "$protonvpn_release_url" -o "$protonvpn_deb" || true
fi

if [[ ! -f "$protonvpn_deb" ]]; then
    exit 0
fi

if ! file "$protonvpn_deb" 2>/dev/null | grep -q "Debian binary"; then
    exit 0
fi

sudo dpkg -i "$protonvpn_deb" || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y || true

# Pin architectures on the Proton repo entry: on Ubuntu 26.04 (amd64v3
# architecture variants) apt can fetch only the binary-all index, and
# python3-proton-vpn-local-agent lives only in binary-amd64, so the
# proton-vpn-gnome-desktop dependencies would be unresolvable.
protonvpn_sources="/etc/apt/sources.list.d/protonvpn-stable.sources"
if [[ -f "$protonvpn_sources" ]] && ! grep -q '^Architectures:' "$protonvpn_sources"; then
    echo 'Architectures: amd64 arm64' | sudo tee -a "$protonvpn_sources" >/dev/null || true
fi

sudo apt-get update -y || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends proton-vpn-gnome-desktop || true
