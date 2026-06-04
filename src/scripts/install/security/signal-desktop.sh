#!/bin/bash

if [[ ! -f /usr/share/keyrings/signal-desktop-keyring.gpg ]]; then
    wget -qO "$TEMP_DIR/signal-key.asc" https://updates.signal.org/desktop/apt/keys.asc || true
    if [[ -f "$TEMP_DIR/signal-key.asc" ]]; then
        gpg --dearmor < "$TEMP_DIR/signal-key.asc" | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg >/dev/null || true
    fi
fi
signal_list="/etc/apt/sources.list.d/signal-xenial.list"
if [[ ! -f "$signal_list" ]] || ! grep -q updates.signal.org "$signal_list" 2>/dev/null; then
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | \
        sudo tee "$signal_list" >/dev/null || true
    sudo apt-get update -y || true
fi
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y signal-desktop
