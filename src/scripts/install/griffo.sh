#!/bin/bash

griffo_key="/etc/apt/trusted.gpg.d/debian.griffo.io.gpg"
if [[ ! -f "$griffo_key" ]]; then
    curl -fsSL https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | \
        sudo gpg --dearmor --yes -o "$griffo_key" || true
fi

griffo_list="/etc/apt/sources.list.d/debian.griffo.io.list"
ubuntu_codename="$(lsb_release -sc 2>/dev/null || echo "")"
if [[ -n "$ubuntu_codename" ]]; then
    if [[ ! -f "$griffo_list" ]] || ! grep -q debian.griffo.io "$griffo_list" 2>/dev/null; then
        echo "deb https://debian.griffo.io/apt $ubuntu_codename main" | \
            sudo tee "$griffo_list" >/dev/null || true
    fi
fi
