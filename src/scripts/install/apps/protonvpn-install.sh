#!/bin/bash

protonvpn_deb="${TEMP_DIR:-/tmp}/protonvpn-stable-release.deb"
protonvpn_release_url="https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb"

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
sudo apt-get update -y || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends proton-vpn-gnome-desktop || true
