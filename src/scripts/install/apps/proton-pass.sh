#!/bin/bash
# Proton Pass desktop .deb — URL from version.json (see proton.me/support/set-up-proton-pass-linux).
# Installs via apt-get (not dpkg -i) so it waits for the dpkg lock when other
# .deb installers run in parallel.

if command -v proton-pass >/dev/null 2>&1 || dpkg -s proton-pass >/dev/null 2>&1; then
    exit 0
fi

proton_pass_deb="$TEMP_DIR/proton-pass.deb"
json_path="$TEMP_DIR/proton-pass-version.json"
curl -fsSL --retry 3 --retry-delay 2 -A "Mozilla/5.0 (X11; Linux x86_64)" \
    "https://proton.me/download/pass/linux/version.json" -o "$json_path" || exit 1

deb_url=$(grep -oE 'https://[^"]+proton-pass_[^"]*_amd64\.deb' "$json_path" | head -1)
if [[ -z "$deb_url" ]]; then
    exit 1
fi

if curl -fsSL --connect-timeout 30 --max-time 600 --retry 3 --retry-delay 2 \
    -A "Mozilla/5.0 (X11; Linux x86_64)" "$deb_url" -o "$proton_pass_deb"; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$proton_pass_deb" || exit 1
fi
