#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
if [[ ! -f "/usr/share/keyrings/signal-desktop-keyring.gpg" ]]; then
    temp_key_file="$TEMP_DIR/signal-key.asc"
    wget -O "$temp_key_file" https://updates.signal.org/desktop/apt/keys.asc 2>>"$ERROR_LOG_FILE" || true
    if [[ -f "$temp_key_file" ]]; then
        gpg --dearmor < "$temp_key_file" 2>>"$ERROR_LOG_FILE" | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null 2>>"$ERROR_LOG_FILE" || true
    fi
fi
signal_list_file="/etc/apt/sources.list.d/signal-xenial.list"
if [[ ! -f "$signal_list_file" ]] || ! grep -q "updates.signal.org" "$signal_list_file" 2>/dev/null; then
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' 2>>"$ERROR_LOG_FILE" | \
        sudo tee "$signal_list_file" > /dev/null 2>>"$ERROR_LOG_FILE" || true
    update_apt_cache
fi
install_apt_packages "signal-desktop"
