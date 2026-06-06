#!/bin/bash
protonvpn_deb="$TEMP_DIR/protonvpn-stable-release.deb"
if [[ ! -f "$protonvpn_deb" ]]; then
    exit 0
fi
file "$protonvpn_deb" 2>/dev/null | grep -q "Debian binary" || exit 0
sudo dpkg -i "$protonvpn_deb" || true
