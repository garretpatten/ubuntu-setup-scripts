#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

local defense_tools=(
    "clamav"
    "clamav-daemon"
    "ufw"
    "openvpn"
)
install_apt_packages "${defense_tools[@]}"

sudo ufw --force reset 2>>"$ERROR_LOG_FILE" || true
sudo ufw default deny incoming 2>>"$ERROR_LOG_FILE" || true
sudo ufw default allow outgoing 2>>"$ERROR_LOG_FILE" || true
sudo ufw allow ssh 2>>"$ERROR_LOG_FILE" || true
sudo ufw --force enable 2>>"$ERROR_LOG_FILE" || true

sudo freshclam 2>>"$ERROR_LOG_FILE" || true

local protonvpn_deb="$TEMP_DIR/protonvpn-stable-release.deb"
download_file_safe "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb" "$protonvpn_deb"
if [[ -f "$protonvpn_deb" ]]; then
    sudo dpkg -i "$protonvpn_deb" 2>>"$ERROR_LOG_FILE" || true
    update_apt_cache
    local protonvpn_packages=(
        "proton-vpn-gnome-desktop"
        "libayatana-appindicator3-1"
        "gir1.2-ayatanaappindicator3-0.1"
        "gnome-shell-extension-appindicator"
    )
    install_apt_packages "${protonvpn_packages[@]}"
fi

local proton_pass_deb="$TEMP_DIR/proton-pass.deb"
download_file_safe "https://proton.me/download/PassDesktop/linux/x64/ProtonPass.deb" "$proton_pass_deb"
if [[ -f "$proton_pass_deb" ]]; then
    sudo dpkg -i "$proton_pass_deb" 2>>"$ERROR_LOG_FILE" || true
    sudo apt-get install -f -y 2>>"$ERROR_LOG_FILE" || true
fi

local proton_pass_cli="$TEMP_DIR/proton-pass-cli"
download_file_safe "https://github.com/protonpass/cli/releases/latest/download/protonpass-cli-linux-amd64" "$proton_pass_cli"
if [[ -f "$proton_pass_cli" ]]; then
    chmod +x "$proton_pass_cli"
    sudo mv "$proton_pass_cli" /usr/local/bin/protonpass 2>>"$ERROR_LOG_FILE" || true
fi

if [[ ! -f "/usr/share/keyrings/signal-desktop-keyring.gpg" ]]; then
    local temp_key_file="$TEMP_DIR/signal-key.asc"
    wget -O "$temp_key_file" https://updates.signal.org/desktop/apt/keys.asc 2>>"$ERROR_LOG_FILE" || true
    if [[ -f "$temp_key_file" ]]; then
        gpg --dearmor < "$temp_key_file" | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null 2>>"$ERROR_LOG_FILE" || true
    fi
fi

local signal_list_file="/etc/apt/sources.list.d/signal-xenial.list"
if [[ ! -f "$signal_list_file" ]] || ! grep -q "updates.signal.org" "$signal_list_file" 2>/dev/null; then
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | \
        sudo tee "$signal_list_file" > /dev/null
    update_apt_cache
fi
install_apt_packages "signal-desktop"

local apt_security_tools=(
    "nmap"
    "exiftool"
)
install_apt_packages "${apt_security_tools[@]}"

if command -v snap >/dev/null 2>&1; then
    sudo snap install zaproxy --classic 2>>"$ERROR_LOG_FILE" || true
fi

ensure_directory "$HOME/Hacking"

if [[ ! -d "$HOME/Hacking/PayloadsAllTheThings" ]]; then
    clone_repository_safe "https://github.com/swisskyrepo/PayloadsAllTheThings" "$HOME/Hacking/PayloadsAllTheThings"
fi

if [[ ! -d "$HOME/Hacking/SecLists" ]]; then
    clone_repository_safe "https://github.com/danielmiessler/SecLists" "$HOME/Hacking/SecLists"
fi
