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
fi
