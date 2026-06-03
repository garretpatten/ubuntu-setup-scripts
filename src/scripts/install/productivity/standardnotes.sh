#!/bin/bash

if flatpak info org.standardnotes.standardnotes >/dev/null 2>&1; then
    exit 0
fi

if flatpak remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install -y flathub org.standardnotes.standardnotes || true
fi

if flatpak info org.standardnotes.standardnotes >/dev/null 2>&1; then
    exit 0
fi

if flatpak --user remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install --user -y flathub org.standardnotes.standardnotes || true
fi
