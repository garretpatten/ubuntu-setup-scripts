#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

install_apt_packages "flatpak"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>>"$ERROR_LOG_FILE" || true

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

sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch 2>>"$ERROR_LOG_FILE" || true
update_apt_cache
install_apt_packages "fastfetch"
