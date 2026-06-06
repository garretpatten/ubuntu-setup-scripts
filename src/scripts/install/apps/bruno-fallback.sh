#!/bin/bash

if command -v bruno >/dev/null 2>&1; then
    exit 0
fi

if flatpak --user info com.usebruno.Bruno >/dev/null 2>&1; then
    exit 0
fi

if flatpak --user remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install --user -y --noninteractive flathub com.usebruno.Bruno || true
elif flatpak remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install -y --noninteractive flathub com.usebruno.Bruno || true
fi
