#!/bin/bash

if command -v zoom >/dev/null 2>&1; then
    exit 0
fi

if flatpak remote-info flathub >/dev/null 2>&1; then
    flatpak install -y flathub us.zoom.Zoom || true
elif flatpak --user remote-info flathub >/dev/null 2>&1; then
    flatpak install --user -y flathub us.zoom.Zoom || true
fi
if command -v zoom >/dev/null 2>&1; then
    exit 0
fi
if flatpak info us.zoom.Zoom >/dev/null 2>&1; then
    exit 0
fi
if flatpak --user info us.zoom.Zoom >/dev/null 2>&1; then
    exit 0
fi

if command -v snap >/dev/null 2>&1; then
    sudo snap install zoom-client || true
fi
