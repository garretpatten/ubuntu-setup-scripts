#!/bin/bash

if command -v zoom >/dev/null 2>&1; then
    exit 0
fi

zoom_deb="$TEMP_DIR/zoom_amd64.deb"
sudo dpkg --add-architecture i386 2>/dev/null || true
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y || true

if curl -fsSL --retry 3 --retry-delay 2 -A "Mozilla/5.0 (X11; Linux x86_64)" \
    https://zoom.us/client/latest/zoom_amd64.deb -o "$zoom_deb"; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$zoom_deb" || true
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y --no-install-recommends || true
fi
if command -v zoom >/dev/null 2>&1; then
    exit 0
fi

if command -v snap >/dev/null 2>&1; then
    sudo systemctl start snapd.socket snapd.seeded.service 2>/dev/null || true
    sudo snap install zoom-client || true
fi
if command -v zoom >/dev/null 2>&1; then
    exit 0
fi
if command -v snap >/dev/null 2>&1 && snap list zoom-client 2>/dev/null | grep -q '^zoom-client '; then
    exit 0
fi

if flatpak remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install -y --noninteractive flathub us.zoom.Zoom || true
elif flatpak --user remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install --user -y --noninteractive flathub us.zoom.Zoom || true
fi
