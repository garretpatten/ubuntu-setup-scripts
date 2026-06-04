#!/bin/bash

if command -v bruno >/dev/null 2>&1; then
    exit 0
fi

bruno_keyring="/etc/apt/keyrings/bruno.gpg"
if [[ ! -f "$bruno_keyring" ]]; then
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x9FA6017ECABE0266" | \
        sudo gpg --dearmor -o "$bruno_keyring" || true
    sudo chmod 644 "$bruno_keyring" 2>/dev/null || true
fi

bruno_list="/etc/apt/sources.list.d/bruno.list"
if [[ ! -f "$bruno_list" ]] || ! grep -q debian.usebruno.com "$bruno_list" 2>/dev/null; then
    echo "deb [arch=amd64 signed-by=$bruno_keyring] http://debian.usebruno.com/ bruno stable" | \
        sudo tee "$bruno_list" >/dev/null || true
    sudo apt-get update -y || true
fi

if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y bruno; then
    exit 0
fi

if flatpak --user info com.usebruno.Bruno >/dev/null 2>&1; then
    exit 0
fi

if flatpak --user remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install --user -y --noninteractive flathub com.usebruno.Bruno || true
elif flatpak remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install -y --noninteractive flathub com.usebruno.Bruno || true
fi
