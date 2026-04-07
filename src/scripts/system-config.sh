#!/bin/bash

# Ubuntu Desktop: GNOME defaults, unattended upgrades, and a few system-wide settings.
# Run from a logged-in session for gsettings; headless installs skip those steps.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/utils.sh"

if [[ "$OSTYPE" != linux-gnu* ]]; then
    log_error "system-config.sh targets Linux (Ubuntu)"
    exit 1
fi

ensure_directory "$HOME/Pictures/Screenshots"

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

install_apt_packages unattended-upgrades

auto_upgrades="/etc/apt/apt.conf.d/20auto-upgrades"
if [[ ! -f "$auto_upgrades" ]]; then
    {
        echo 'APT::Periodic::Update-Package-Lists "1";'
        echo 'APT::Periodic::Download-Upgradeable-Packages "0";'
        echo 'APT::Periodic::AutocleanInterval "0";'
        echo 'APT::Periodic::Unattended-Upgrade "1";'
    } | sudo tee "$auto_upgrades" >/dev/null 2>>"$ERROR_LOG_FILE" || true
fi

sudo env ERROR_LOG_FILE="$ERROR_LOG_FILE" bash -c '
gdm_conf="/etc/gdm3/custom.conf"
if [[ -f "$gdm_conf" ]] && ! grep -qE "^AllowGuest=false" "$gdm_conf" 2>/dev/null && grep -q "^\[daemon\]" "$gdm_conf" 2>/dev/null; then
    sed -i "/^\[daemon\]/a AllowGuest=false" "$gdm_conf" 2>>"$ERROR_LOG_FILE" || true
fi

if [[ -f /etc/default/apport ]]; then
    sed -i "s/^enabled=.*/enabled=0/" /etc/default/apport 2>>"$ERROR_LOG_FILE" || true
fi
# Best-effort; apport is often not a native unit on minimal/CI images (noisy stderr).
systemctl stop apport.service 2>/dev/null || true
systemctl disable apport.service 2>/dev/null || true

logind_dropin="/etc/systemd/logind.conf.d/50-lid.conf"
mkdir -p "$(dirname "$logind_dropin")" 2>>"$ERROR_LOG_FILE" || true
if [[ ! -f "$logind_dropin" ]]; then
    printf "%s\n" "[Login]" "HandleLidSwitch=suspend" "HandleLidSwitchExternalPower=suspend" "HandleLidSwitchDocked=ignore" >"$logind_dropin"
fi
systemctl try-restart systemd-logind.service 2>>"$ERROR_LOG_FILE" || true

sysctl_conf="/etc/sysctl.d/99-tcp-keepalive.conf"
if [[ ! -f "$sysctl_conf" ]]; then
    printf "%s\n" \
        "net.ipv4.tcp_keepalive_time = 600" \
        "net.ipv4.tcp_keepalive_intvl = 30" \
        "net.ipv4.tcp_keepalive_probes = 5" \
        >"$sysctl_conf"
fi
sysctl --system 2>>"$ERROR_LOG_FILE" || true
' || true
