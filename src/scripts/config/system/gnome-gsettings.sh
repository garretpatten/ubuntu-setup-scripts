#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
if [[ "$OSTYPE" != linux-gnu* ]]; then exit 0; fi
if gsettings_ok; then
    gsettings_set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings_set org.gnome.desktop.interface enable-animations false
    gsettings_set org.gnome.desktop.interface clock-show-date true
    gsettings_set org.gnome.desktop.interface clock-show-weekday true
    gsettings_set org.gnome.desktop.interface clock-format 12h
    gsettings_set org.gnome.desktop.interface show-battery-percentage false

    gsettings_set org.gnome.desktop.peripherals.touchpad natural-scroll false
    gsettings_set org.gnome.desktop.peripherals.mouse natural-scroll false
    gsettings_set org.gnome.desktop.peripherals.keyboard delay 200
    gsettings_set org.gnome.desktop.peripherals.keyboard repeat-interval 15

    gsettings_set org.gnome.nautilus.preferences show-hidden-files true
    gsettings_set org.gnome.nautilus.preferences show-image-thumbnails true
    gsettings_set org.gnome.nautilus.preferences default-folder-viewer list-view
    gsettings_set org.gnome.nautilus.preferences always-use-location-entry true
    gsettings_set org.gnome.nautilus.preferences recursive-search local-only

    gsettings_set org.gnome.gnome-screenshot auto-save-directory "file://${HOME}/Pictures/Screenshots"
    gsettings_set org.gnome.desktop.screenshots include-border false

    if gsettings_schema_exists org.gnome.shell.extensions.dash-to-dock; then
        gsettings_set org.gnome.shell.extensions.dash-to-dock autohide true
        gsettings_set org.gnome.shell.extensions.dash-to-dock autohide-delay 0.0
        gsettings_set org.gnome.shell.extensions.dash-to-dock animation-time 0.1
        gsettings_set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    fi

    gsettings_set org.gnome.desktop.search-providers disable-external false

    if gsettings_schema_exists org.gnome.settings-daemon.plugins.color; then
        gsettings_set org.gnome.settings-daemon.plugins.color night-light-enabled true
        gsettings_set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
        gsettings_set org.gnome.settings-daemon.plugins.color night-light-temperature 2700
    fi

    gsettings_set org.gnome.desktop.screensaver lock-enabled true
    gsettings_set org.gnome.desktop.session idle-delay 600
    gsettings_set org.gnome.desktop.screensaver idle-activation-enabled true
    gsettings_set org.gnome.desktop.screensaver lock-delay 0

    gsettings_set org.gnome.desktop.privacy remember-recent-files false
    gsettings_set org.gnome.desktop.privacy remove-old-temp-files true
fi
