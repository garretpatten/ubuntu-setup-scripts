#!/bin/bash
protonvpn_deb="$TEMP_DIR/protonvpn-stable-release.deb"
curl -fsSL https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb -o "$protonvpn_deb" || true
