#!/bin/bash

if command -v zaproxy >/dev/null 2>&1; then
    exit 0
fi

if flatpak remote-info flathub >/dev/null 2>&1; then
    flatpak install -y flathub org.zaproxy.ZAP || true
elif flatpak --user remote-info flathub >/dev/null 2>&1; then
    flatpak install --user -y flathub org.zaproxy.ZAP || true
fi
if command -v zaproxy >/dev/null 2>&1; then
    exit 0
fi
if flatpak info org.zaproxy.ZAP >/dev/null 2>&1; then
    exit 0
fi
if flatpak --user info org.zaproxy.ZAP >/dev/null 2>&1; then
    exit 0
fi

if command -v snap >/dev/null 2>&1; then
    sudo snap install zaproxy --classic || true
fi
