#!/bin/bash

if command -v google-chrome >/dev/null 2>&1; then
    exit 0
fi
if dpkg -s google-chrome-stable >/dev/null 2>&1; then
    exit 0
fi

chrome_deb="$TEMP_DIR/google-chrome-stable.deb"
chrome_url="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

curl -fsSL --retry 3 --retry-delay 2 "$chrome_url" -o "$chrome_deb" || exit 0
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$chrome_deb" || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y --no-install-recommends || true
