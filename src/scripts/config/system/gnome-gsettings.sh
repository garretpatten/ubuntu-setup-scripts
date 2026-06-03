#!/bin/bash

[[ "$OSTYPE" == linux-gnu* ]] || exit 0

# shellcheck source=../../lib/gnome-session.sh
source "$(dirname "$0")/../../lib/gnome-session.sh"
gnome_session_active || exit 0

command -v gsettings >/dev/null 2>&1 || exit 0
[[ -S "/run/user/$(id -u)/bus" ]] || exit 0
gsettings list-schemas 2>/dev/null | grep -qx org.gnome.desktop.interface || exit 0

gsettings set org.gnome.desktop.interface color-scheme prefer-dark || true
gsettings set org.gnome.desktop.interface enable-animations false || true
gsettings set org.gnome.desktop.interface clock-show-date true || true
gsettings set org.gnome.desktop.interface clock-show-weekday true || true
gsettings set org.gnome.desktop.interface clock-format 12h || true
gsettings set org.gnome.desktop.interface show-battery-percentage false || true

gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false || true
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false || true
gsettings set org.gnome.desktop.peripherals.keyboard delay 200 || true
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 15 || true

gsettings set org.gnome.nautilus.preferences show-hidden-files true || true
gsettings set org.gnome.nautilus.preferences show-image-thumbnails true || true
gsettings set org.gnome.nautilus.preferences default-folder-viewer list-view || true
gsettings set org.gnome.nautilus.preferences always-use-location-entry true || true
gsettings set org.gnome.nautilus.preferences recursive-search local-only || true

gsettings set org.gnome.gnome-screenshot auto-save-directory "file://${HOME}/Pictures/Screenshots" || true
gsettings set org.gnome.desktop.screenshots include-border false || true

if command -v gnome-extensions >/dev/null 2>&1; then
    gnome-extensions disable ubuntu-dock@ubuntu.com || true
fi

gsettings set org.gnome.desktop.search-providers disable-external false || true

if gsettings list-schemas 2>/dev/null | grep -qx org.gnome.settings-daemon.plugins.color; then
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true || true
    gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true || true
    gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 2700 || true
fi

gsettings set org.gnome.desktop.screensaver lock-enabled true || true
gsettings set org.gnome.desktop.session idle-delay 600 || true
gsettings set org.gnome.desktop.screensaver idle-activation-enabled true || true
gsettings set org.gnome.desktop.screensaver lock-delay 0 || true

gsettings set org.gnome.desktop.privacy remember-recent-files false || true
gsettings set org.gnome.desktop.privacy remove-old-temp-files true || true
