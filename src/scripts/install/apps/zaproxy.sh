#!/bin/bash

if command -v zaproxy >/dev/null 2>&1; then
    exit 0
fi

if command -v snap >/dev/null 2>&1; then
    sudo systemctl start snapd.socket snapd.seeded.service 2>/dev/null || true
    sudo snap install zaproxy --classic || true
fi
if command -v zaproxy >/dev/null 2>&1; then
    exit 0
fi
if command -v snap >/dev/null 2>&1 && snap list zaproxy 2>/dev/null | grep -q '^zaproxy '; then
    exit 0
fi

if flatpak remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install -y --noninteractive flathub org.zaproxy.ZAP || true
elif flatpak --user remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install --user -y --noninteractive flathub org.zaproxy.ZAP || true
fi
if command -v zaproxy >/dev/null 2>&1; then
    exit 0
fi
if flatpak info org.zaproxy.ZAP >/dev/null 2>&1; then
    exit 0
fi
if flatpak --user info org.zaproxy.ZAP >/dev/null 2>&1; then
    exit 0
fi

zap_tgz="$TEMP_DIR/zap-linux.tar.gz"
zap_url=$(curl -fsSL https://api.github.com/repos/zaproxy/zaproxy/releases/latest 2>/dev/null | \
    grep 'browser_download_url.*Linux.tar.gz' | head -1 | cut -d '"' -f 4)
if [[ -z "$zap_url" ]]; then
    zap_url="https://github.com/zaproxy/zaproxy/releases/download/v2.17.0/ZAP_2.17.0_Linux.tar.gz"
fi
if curl -fsSL --retry 3 --retry-delay 2 "$zap_url" -o "$zap_tgz"; then
    sudo rm -rf /opt/zap
    sudo mkdir -p /opt/zap
    if sudo tar -xzf "$zap_tgz" -C /opt/zap --strip-components=1; then
        if [[ -f /opt/zap/zap.sh ]]; then
            sudo tee /usr/local/bin/zaproxy >/dev/null <<'EOF'
#!/bin/bash
exec /opt/zap/zap.sh "$@"
EOF
            sudo chmod +x /usr/local/bin/zaproxy
        fi
    fi
fi
