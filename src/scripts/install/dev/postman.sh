#!/bin/bash

if flatpak --user remote-info flathub >/dev/null 2>&1; then
    flatpak install --user -y --noninteractive flathub com.getpostman.Postman || true
elif flatpak remote-info flathub >/dev/null 2>&1; then
    flatpak install -y --noninteractive flathub com.getpostman.Postman || true
fi
