#!/bin/bash
flatpak remote-info flathub >/dev/null 2>&1 &&     flatpak install -y flathub org.standardnotes.standardnotes || true
