#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
protonvpn_deb="$TEMP_DIR/protonvpn-stable-release.deb"
download_file_safe "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb" "$protonvpn_deb"
if [[ -f "$protonvpn_deb" ]] && [[ -s "$protonvpn_deb" ]]; then
    if file "$protonvpn_deb" 2>/dev/null | grep -q "Debian binary"; then
        sudo dpkg -i "$protonvpn_deb" 2>>"$ERROR_LOG_FILE" || true
        update_apt_cache
        install_apt_packages "proton-vpn-gnome-desktop" "libayatana-appindicator3-1" \
            "gir1.2-ayatanaappindicator3-0.1" "gnome-shell-extension-appindicator"
    fi
fi
