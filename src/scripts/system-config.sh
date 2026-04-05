#!/bin/bash

# Desktop and system-wide preferences for Ubuntu (GNOME): appearance, input,
# privacy, updates, power/session, Files, Dock, search, Night Light, and
# developer-oriented defaults. Run on Ubuntu Desktop; headless/minimal installs
# skip gsettings-only steps. Re-login or restart GNOME Shell for some changes.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

if [[ "$OSTYPE" != linux-gnu* ]]; then
    log_error "system-config.sh targets Linux (Ubuntu)"
    exit 1
fi

# True when gsettings is available and can talk to a session (Wayland/X11 desktop).
gsettings_available() {
    command -v gsettings >/dev/null 2>&1 && [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" || -n "${WAYLAND_DISPLAY:-}" || -n "${DISPLAY:-}" || -S /run/user/"$(id -u)"/bus ]]
}

gsettings_set() {
    # shellcheck disable=SC2068
    gsettings set "$@" 2>>"$ERROR_LOG_FILE" || true
}

schema_exists() {
    gsettings list-schemas 2>>"$ERROR_LOG_FILE" | grep -qx "$1"
}

# --- Appearance & interface (GNOME) ---
if gsettings_available; then
    gsettings_set org.gnome.desktop.interface color-scheme prefer-dark

    # Fewer UI animations (snappier feedback)
    gsettings_set org.gnome.desktop.interface enable-animations false

    # Date + weekday in top bar (closest to macOS clock density)
    gsettings_set org.gnome.desktop.interface clock-show-date true
    gsettings_set org.gnome.desktop.interface clock-show-weekday true
    if gsettings range org.gnome.desktop.interface clock-format &>/dev/null; then
        gsettings_set org.gnome.desktop.interface clock-format 12h
    fi

    # Hide battery percentage in status area (top bar)
    if gsettings writable org.gnome.desktop.interface show-battery-percentage &>/dev/null; then
        gsettings_set org.gnome.desktop.interface show-battery-percentage false
    fi
fi

# --- Input: keyboard & pointer ---
if gsettings_available; then
    # Natural scrolling OFF (classic / non-natural) for touchpad and mouse
    gsettings_set org.gnome.desktop.peripherals.touchpad natural-scroll false
    gsettings_set org.gnome.desktop.peripherals.mouse natural-scroll false

    # Fast key repeat & short delay (GNOME uses ms; lower repeat-interval = faster)
    gsettings_set org.gnome.desktop.peripherals.keyboard delay 200
    gsettings_set org.gnome.desktop.peripherals.keyboard repeat-interval 15

    # Three-finger drag has no single gsettings key; use libinput quirks, touchegg, or GNOME tweaks/extensions if needed.

    # Click/tap to click: optional; leave default — uncomment if desired:
    # gsettings_set org.gnome.desktop.peripherals.touchpad tap-to-click true
fi

# --- Files (Nautilus): hidden files, list view, path bar, search scope ---
if gsettings_available; then
    gsettings_set org.gnome.nautilus.preferences show-hidden-files true
    if gsettings writable org.gnome.nautilus.preferences show-image-thumbnails &>/dev/null; then
        gsettings_set org.gnome.nautilus.preferences show-image-thumbnails true
    fi
    gsettings_set org.gnome.nautilus.preferences default-folder-viewer list-view
    # Editable location bar shows full path (similar to path in title / path bar)
    gsettings_set org.gnome.nautilus.preferences always-use-location-entry true
    # Prefer searching the current folder / locality over “entire machine”
    if gsettings writable org.gnome.nautilus.preferences recursive-search &>/dev/null; then
        gsettings_set org.gnome.nautilus.preferences recursive-search local-only
    fi
fi

# --- Screenshots: folder + no shadow (GNOME screenshot tool) ---
ensure_directory "$HOME/Pictures/Screenshots"
if gsettings_available; then
    screenshot_dir="file://${HOME}/Pictures/Screenshots"
    gsettings_set org.gnome.gnome-screenshot auto-save-directory "$screenshot_dir"
    if schema_exists org.gnome.desktop.screenshots; then
        gsettings_set org.gnome.desktop.screenshots include-border false
    fi
fi

# --- Dock (Dash to Dock on Ubuntu) ---
if gsettings_available && schema_exists org.gnome.shell.extensions.dash-to-dock; then
    gsettings_set org.gnome.shell.extensions.dash-to-dock autohide true
    gsettings_set org.gnome.shell.extensions.dash-to-dock autohide-delay 0.0
    gsettings_set org.gnome.shell.extensions.dash-to-dock animation-time 0.1
    gsettings_set org.gnome.shell.extensions.dash-to-dock dock-fixed false
fi

# --- Search (GNOME Shell): prioritize apps & settings in overview search ---
if gsettings_available; then
    if gsettings writable org.gnome.desktop.search-providers disable-external &>/dev/null; then
        gsettings_set org.gnome.desktop.search-providers disable-external false
    fi
fi

# --- Night Light (equivalent to Night Shift: warm tint, sunset–sunrise schedule) ---
# Note: productivity.sh installs redshift; use either Night Light or redshift, not both.
if gsettings_available && schema_exists org.gnome.settings-daemon.plugins.color; then
    gsettings_set org.gnome.settings-daemon.plugins.color night-light-enabled true
    if gsettings writable org.gnome.settings-daemon.plugins.color night-light-schedule-automatic &>/dev/null; then
        gsettings_set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
    fi
    # Warmest end of the slider (Kelvin-style internal scale; ~lower = warmer on many versions)
    if gsettings range org.gnome.settings-daemon.plugins.color night-light-temperature &>/dev/null; then
        gsettings_set org.gnome.settings-daemon.plugins.color night-light-temperature 2700
    fi
fi

# --- Automatic updates & security-related maintenance (APT) ---
install_apt_packages unattended-upgrades

auto_upgrades="/etc/apt/apt.conf.d/20auto-upgrades"
# Do not overwrite Ubuntu’s file if present; only seed when missing.
if [[ ! -f "$auto_upgrades" ]]; then
    {
        echo 'APT::Periodic::Update-Package-Lists "1";'
        echo 'APT::Periodic::Download-Upgradeable-Packages "0";'
        echo 'APT::Periodic::AutocleanInterval "0";'
        echo 'APT::Periodic::Unattended-Upgrade "1";'
    } | sudo tee "$auto_upgrades" >/dev/null 2>>"$ERROR_LOG_FILE" || true
fi

# --- Single sudo session: guest login, crash reports, session/power, sysctl ---
sudo env ERROR_LOG_FILE="$ERROR_LOG_FILE" bash -c '
    # Disable guest session (GDM on Ubuntu Desktop)
    gdm_conf="/etc/gdm3/custom.conf"
    if [[ -f "$gdm_conf" ]] && ! grep -qE "^AllowGuest=false" "$gdm_conf" 2>/dev/null; then
        if grep -q "^\[daemon\]" "$gdm_conf" 2>/dev/null; then
            sed -i "/^\[daemon\]/a AllowGuest=false" "$gdm_conf" 2>>"$ERROR_LOG_FILE" || true
        fi
    fi

    # Fewer intrusive crash dialogs (Apport); logs remain for investigation
    if [[ -f /etc/default/apport ]]; then
        sed -i "s/^enabled=.*/enabled=0/" /etc/default/apport 2>>"$ERROR_LOG_FILE" || true
    fi
    systemctl stop apport.service 2>>"$ERROR_LOG_FILE" || true
    systemctl disable apport.service 2>>"$ERROR_LOG_FILE" || true

    # Lid: suspend when closed; wake is default when opened (Apple Silicon pmset lidwake analog)
    logind_dropin="/etc/systemd/logind.conf.d/50-lid.conf"
    mkdir -p "$(dirname "$logind_dropin")" 2>>"$ERROR_LOG_FILE" || true
    if [[ ! -f "$logind_dropin" ]]; then
        cat > "$logind_dropin" <<EOF
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
EOF
    fi
    systemctl try-restart systemd-logind.service 2>>"$ERROR_LOG_FILE" || true

    # TCP keepalive tuning (broadly similar intent to macOS pmset tcpkeepalive for idle connections)
    sysctl_conf="/etc/sysctl.d/99-tcp-keepalive.conf"
    if [[ ! -f "$sysctl_conf" ]]; then
        cat > "$sysctl_conf" <<EOF
# Slightly more aggressive keepalives for long-lived SSH/dev sessions (safe defaults)
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 5
EOF
    fi
    sysctl --system 2>>"$ERROR_LOG_FILE" || true
' || true

# --- Screensaver / lock: lock on resume; no delay before lock after idle ---
if gsettings_available; then
    gsettings_set org.gnome.desktop.screensaver lock-enabled true
    # Seconds until screen blanks (600 = 10 min); lock applies when the session locks
    gsettings_set org.gnome.desktop.session idle-delay 600
    gsettings_set org.gnome.desktop.screensaver idle-activation-enabled true
    gsettings_set org.gnome.desktop.screensaver lock-delay 0
fi

# --- Privacy: recent files in GTK / privacy (limit “recent” metadata) ---
if gsettings_available; then
    gsettings_set org.gnome.desktop.privacy remember-recent-files false
    gsettings_set org.gnome.desktop.privacy remove-old-temp-files true
fi
