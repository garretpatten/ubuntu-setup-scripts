#!/bin/bash

if flatpak remote-info flathub >/dev/null 2>&1; then
    flatpak install -y flathub org.standardnotes.standardnotes || true
elif flatpak --user remote-info flathub >/dev/null 2>&1; then
    flatpak install --user -y flathub org.standardnotes.standardnotes || true
fi
