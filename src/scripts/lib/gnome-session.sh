#!/bin/bash

# True when the active session is GNOME (Ubuntu Desktop, GNOME Wayland/Xorg, etc.).

gnome_session_active() {
    local desktop="${XDG_CURRENT_DESKTOP:-}"
    local session="${DESKTOP_SESSION:-}"

    if [[ "$desktop" == *[Gg][Nn][Oo][Mm][Ee]* ]]; then
        return 0
    fi

    case "$session" in
        gnome | gnome-xorg | gnome-wayland | gnome-classic | ubuntu | ubuntu-wayland)
            return 0
            ;;
    esac

    [[ -n "${GNOME_SHELL_SESSION_MODE:-}" ]] && return 0

    command -v loginctl >/dev/null 2>&1 || return 1

    local sid desktop_name user
    while read -r sid _ _ user _; do
        [[ "$user" == "$USER" ]] || continue
        desktop_name=$(loginctl show-session "$sid" -p Desktop --value 2>/dev/null || true)
        if [[ "$desktop_name" == GNOME || "$desktop_name" == gnome ]]; then
            return 0
        fi
    done < <(loginctl list-sessions --no-legend 2>/dev/null)

    return 1
}
