#!/bin/bash
# Proton Pass desktop .deb — URL from version.json (see proton.me/support/set-up-proton-pass-linux).

if ! command -v proton-pass >/dev/null 2>&1 && ! dpkg -s proton-pass >/dev/null 2>&1; then
    proton_pass_deb="$TEMP_DIR/proton-pass.deb"
    json_path="$TEMP_DIR/proton-pass-version.json"
    if curl -fsSL --retry 3 --retry-delay 2 -A "Mozilla/5.0 (X11; Linux x86_64)" \
        "https://proton.me/download/pass/linux/version.json" -o "$json_path"; then
        deb_url=$(grep -oE 'https://[^"]+proton-pass_[^"]*_amd64\.deb' "$json_path" | head -1)
        if [[ -n "$deb_url" ]] && curl -fsSL --connect-timeout 30 --max-time 600 --retry 3 --retry-delay 2 \
            -A "Mozilla/5.0 (X11; Linux x86_64)" "$deb_url" -o "$proton_pass_deb"; then
            sudo dpkg -i "$proton_pass_deb" || true
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y --no-install-recommends || true
        fi
    fi
fi
