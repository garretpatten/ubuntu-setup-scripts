#!/bin/bash

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y flatpak

# System flathub remote (normal desktop install). Fall back to per-user on hosts that block ConfigureRemote.
if ! sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1 || true
fi
