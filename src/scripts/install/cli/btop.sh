#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
ubuntu_release="$(lsb_release -rs 2>/dev/null || echo "")"
if [[ -n "$ubuntu_release" ]] && dpkg --compare-versions "$ubuntu_release" ge 22.04 2>/dev/null; then
    install_apt_packages "btop"
elif command -v snap >/dev/null 2>&1; then
    sudo snap install btop 2>>"$ERROR_LOG_FILE" || true
fi
