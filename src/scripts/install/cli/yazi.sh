#!/bin/bash

yazi_key="/etc/apt/trusted.gpg.d/debian.griffo.io.gpg"
if [[ ! -f "$yazi_key" ]]; then
    curl -fsSL https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | \
        sudo gpg --dearmor --yes -o "$yazi_key" || true
fi

yazi_list="/etc/apt/sources.list.d/debian.griffo.io.list"
ubuntu_codename="$(lsb_release -sc 2>/dev/null || echo "")"
if [[ -n "$ubuntu_codename" ]]; then
    if [[ ! -f "$yazi_list" ]] || ! grep -q debian.griffo.io "$yazi_list" 2>/dev/null; then
        echo "deb https://debian.griffo.io/apt $ubuntu_codename main" | \
            sudo tee "$yazi_list" >/dev/null || true
        sudo apt-get update -y || true
    fi
fi

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y yazi
