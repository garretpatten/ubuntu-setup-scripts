#!/bin/bash

source "$(pwd)/src/scripts/utils.sh"

### Authentication ###

# 1Password
if [[ ! -f "/usr/bin/1password" ]]; then
    # 1Password desktop app
    curl -sSO https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz
    sudo tar -xf 1password-latest.tar.gz
    sudo mkdir -p /opt/1Password
    sudo mv 1password-*/* /opt/1Password
    sudo /opt/1Password/after-install.sh

    # 1Password CLI
    sudo curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
    sudo tee /etc/apt/sources.list.d/1password.list
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    sudo curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
    sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    sudo curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
    sudo apt-get update -y && sudo apt-get install 1password-cli -y
fi

### Defense ###

# Clam AV
if ! is_installed "clamscan"; then
    sudo apt install clamav -y
fi

# Firewall
if ! is_installed "ufw"; then
    sudo apt install ufw -y
fi
sudo ufw enable

# Open VPN
if ! is_installed "openvpn"; then
    sudo apt-get install openvpn -y
fi

# Proton VPN, Proton VPN CLI, and system tray icon
if [[ ! -f "/usr/bin/protonvpn" ]]; then
    sudo apt install gnome-shell -y
    currentWorkingDirectory=$(pwd)
    cd "$HOME/Downloads/" || return
    wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
    sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb && sudo apt update -y
    echo "0b14e71586b22e498eb20926c48c7b434b751149b1f2af9902ef1cfe6b03e180 protonvpn-stable-release_1.0.8_all.deb" | sha256sum --check - || {
        echo "Failed to verify Proton VPN package." >> "$ERROR_FILE";
    }
    cd "$currentWorkingDirectory" || return
    sudo apt install proton-vpn-gnome-desktop -y
    sudo apt install libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator -y
fi

# Signal Messenger
if [[ ! -f "/usr/bin/signal-desktop" && ! -f "/bin/signal-desktop" ]]; then
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > "$HOME/signal-desktop-keyring.gpg"
    tee < "$HOME/signal-desktop-keyring.gpg" /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | \
    sudo tee /etc/apt/sources.list.d/signal-xenial.list
    sudo apt-get update -y
    sudo apt-get install signal-desktop -y
fi

### Offensive Security ###

# Burp Suite
if [[ ! -d "usr/local/Caskroom/burp-suite/" ]]; then
    # TODO: Install Burp Suite Community Edition
fi

# EXIF Tool
if ! is_installed "exiftool"; then
    # TODO: Install exiftool
fi

# Network Mapper
if ! is_installed "nmap"; then
    sudo apt-get install nmap -y
fi

# Payloads All the Things
if [[ ! -d "$HOME/Hacking/PayloadsAllTheThings" ]]; then
    git clone https://github.com/swisskyrepo/PayloadsAllTheThings "$HOME/Hacking/" || {
        echo "Failed to clone https://github.com/swisskyrepo/PayloadsAllTheThings" >> "$ERROR_FILE";
    }
fi

# SecLists
if [[ ! -d "$HOME/Hacking/PayloadsAllTheThings" ]]; then
    git clone https://github.com/danielmiessler/SecLists "$HOME/Hacking/" || {
        echo "https://github.com/danielmiessler/SecLists" >> "$ERROR_FILE";
    }
fi

# ZAP
if ! is_installed "zaproxy"; then
    sudo apt install zaproxy -y
fi
