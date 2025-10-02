#!/bin/bash

source "$(pwd)/src/scripts/utils.sh"

### Package managers ###

# Flatpak
if [[ ! -f "/usr/bin/flatpak" ]]; then
    sudo apt install flatpak -y
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

### Tools ###

cliTools=("bat" "curl" "eza" "fastfetch" "fd" "git" "htop" "jq" "ripgrep" "vim" "wget")
for tool in "${cliTools[@]}"; do
    if ! is_installed "$tool"; then
        sudo apt install "$tool" -y
    fi
done

# fastfetch
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
sudo apt update 
sudo apt install fastfetch -y
