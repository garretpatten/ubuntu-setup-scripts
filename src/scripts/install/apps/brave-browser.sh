#!/bin/bash
if [[ ! -f /usr/share/keyrings/brave-browser-archive-keyring.gpg ]]; then
    curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg |         sudo gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg || true
fi
if ! grep -q brave-browser-apt-release /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" |         sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null || true
fi
