#!/bin/bash

if flatpak list --columns=application --app 2>/dev/null | grep -Fxq org.standardnotes.standardnotes; then
    exit 0
fi
if flatpak list --user --columns=application --app 2>/dev/null | grep -Fxq org.standardnotes.standardnotes; then
    exit 0
fi

if flatpak remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install -y --noninteractive flathub org.standardnotes.standardnotes || true
fi

if flatpak list --columns=application --app 2>/dev/null | grep -Fxq org.standardnotes.standardnotes; then
    exit 0
fi

if flatpak --user remote-info flathub >/dev/null 2>&1; then
    dbus-run-session -- flatpak install --user -y --noninteractive flathub org.standardnotes.standardnotes || true
fi
