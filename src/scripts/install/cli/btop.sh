#!/bin/bash
ubuntu_release="$(lsb_release -rs 2>/dev/null || echo "")"
if [[ -n "$ubuntu_release" ]] && dpkg --compare-versions "$ubuntu_release" ge 22.04 2>/dev/null; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y btop
elif command -v snap >/dev/null 2>&1; then
    sudo snap install btop || true
fi
