#!/bin/bash

if flatpak --user info com.getpostman.Postman >/dev/null 2>&1; then
    exit 0
fi

if flatpak --user remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install --user -y --noninteractive flathub com.getpostman.Postman || true
elif flatpak remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install -y --noninteractive flathub com.getpostman.Postman || true
fi
