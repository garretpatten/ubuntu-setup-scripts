#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

local onepassword_tarball="$TEMP_DIR/1password-latest.tar.gz"
download_file_safe "https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz" "$onepassword_tarball"
if [[ -f "$onepassword_tarball" ]]; then
    cd "$TEMP_DIR" || true
    tar -xf "$onepassword_tarball" 2>>"$ERROR_LOG_FILE" || true
    sudo mkdir -p /opt/1Password
    sudo mv 1password-*/* /opt/1Password/ 2>>"$ERROR_LOG_FILE" || true
    sudo /opt/1Password/after-install.sh 2>>"$ERROR_LOG_FILE" || true
fi

if [[ ! -f "/usr/share/keyrings/1password-archive-keyring.gpg" ]]; then
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg 2>>"$ERROR_LOG_FILE" || true

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
        sudo tee /etc/apt/sources.list.d/1password.list > /dev/null

    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
        sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol > /dev/null

    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg 2>>"$ERROR_LOG_FILE" || true

    update_apt_cache
fi
install_apt_packages "1password-cli"

local defense_tools=(
    "clamav"
    "clamav-daemon"
    "ufw"
    "openvpn"
    "gnome-shell"
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

local bridge_deb="$TEMP_DIR/protonmail-bridge.deb"
download_file_safe "https://proton.me/download/bridge/protonmail-bridge_3.9.1-1_amd64.deb" "$bridge_deb"
if [[ -f "$bridge_deb" ]]; then
    sudo dpkg -i "$bridge_deb" 2>>"$ERROR_LOG_FILE" || true
    sudo apt-get install -f -y 2>>"$ERROR_LOG_FILE" || true
fi

curl https://rclone.org/install.sh | sudo bash 2>>"$ERROR_LOG_FILE" || true

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
local repos=(
    "https://github.com/swisskyrepo/PayloadsAllTheThings:PayloadsAllTheThings"
    "https://github.com/danielmiessler/SecLists:SecLists"
)

for repo_info in "${repos[@]}"; do
    local repo_url="${repo_info%:*}"
    local repo_name="${repo_info#*:}"
    local repo_path="$HOME/Hacking/$repo_name"
    if [[ ! -d "$repo_path" ]]; then
        clone_repository_safe "$repo_url" "$repo_path"
    fi
done
