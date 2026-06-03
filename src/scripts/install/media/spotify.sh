#!/bin/bash

if command -v spotify >/dev/null 2>&1; then
    exit 0
fi

ubuntu_release="$(lsb_release -rs 2>/dev/null || echo "")"
if [[ -n "$ubuntu_release" ]] && dpkg --compare-versions "$ubuntu_release" ge 24.04 2>/dev/null; then
    spotify_keyring="/usr/share/keyrings/spotify-archive-keyring.gpg"
    if [[ ! -f "$spotify_keyring" ]]; then
        curl -fsSL https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | \
            sudo gpg --dearmor -o "$spotify_keyring" || true
    fi
    spotify_list="/etc/apt/sources.list.d/spotify.list"
    if [[ ! -f "$spotify_list" ]] || ! grep -q repository.spotify.com "$spotify_list" 2>/dev/null; then
        echo "deb [signed-by=$spotify_keyring arch=amd64] https://repository.spotify.com stable non-free" | \
            sudo tee "$spotify_list" >/dev/null || true
        sudo apt-get update -y || true
    fi
    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y spotify-client; then
        exit 0
    fi
fi

if flatpak remote-info flathub >/dev/null 2>&1; then
    flatpak install -y flathub com.spotify.Client || true
elif flatpak --user remote-info flathub >/dev/null 2>&1; then
    flatpak install --user -y flathub com.spotify.Client || true
fi
if command -v spotify >/dev/null 2>&1; then
    exit 0
fi
if flatpak info com.spotify.Client >/dev/null 2>&1; then
    exit 0
fi
if flatpak --user info com.spotify.Client >/dev/null 2>&1; then
    exit 0
fi

if command -v snap >/dev/null 2>&1; then
    sudo snap install spotify || true
fi
