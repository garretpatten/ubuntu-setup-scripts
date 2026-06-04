#!/bin/bash

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y flatpak dbus-x11

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1 || true
