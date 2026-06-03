#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
if flatpak remote-info flathub >/dev/null 2>&1; then
    flatpak install -y flathub org.standardnotes.standardnotes 2>>"$ERROR_LOG_FILE" || true
fi
