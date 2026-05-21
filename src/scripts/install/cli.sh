#!/bin/bash

# shellcheck source=../utils.sh
source "$(dirname "$0")/../utils.sh"

update_apt_cache

install_apt_packages "flatpak"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

cli_tools=(
    "bat"
    "curl"
    "eza"
    "fd-find"
    "git"
    "htop"
    "jq"
    "ripgrep"
    "vim"
    "wget"
)
install_apt_packages "${cli_tools[@]}"

# btop entered Ubuntu universe in Jammy (22.04); use snap before that.
ubuntu_release="$(lsb_release -rs 2>/dev/null || echo "")"
if [[ -n "$ubuntu_release" ]] && dpkg --compare-versions "$ubuntu_release" ge 22.04 2>/dev/null; then
    install_apt_packages "btop"
elif command -v snap >/dev/null 2>&1; then
    sudo snap install btop 2>>"$ERROR_LOG_FILE" || true
fi

sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch 2>>"$ERROR_LOG_FILE" || true
update_apt_cache
install_apt_packages "fastfetch"
