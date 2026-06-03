#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
restart_logind=1
if desktop_session_active; then
    restart_logind=0
fi
sudo env ERROR_LOG_FILE="$ERROR_LOG_FILE" RESTART_LOGIND="$restart_logind" bash -c '
gdm_conf="/etc/gdm3/custom.conf"
if [[ -f "$gdm_conf" ]] && ! grep -qE "^AllowGuest=false" "$gdm_conf" 2>/dev/null && grep -q "^\[daemon\]" "$gdm_conf" 2>/dev/null; then
    sed -i "/^\[daemon\]/a AllowGuest=false" "$gdm_conf" 2>>"$ERROR_LOG_FILE" || true
fi
if [[ -f /etc/default/apport ]]; then
    sed -i "s/^enabled=.*/enabled=0/" /etc/default/apport 2>>"$ERROR_LOG_FILE" || true
fi
systemctl stop apport.service 2>/dev/null || true
systemctl disable apport.service 2>/dev/null || true
logind_dropin="/etc/systemd/logind.conf.d/50-lid.conf"
mkdir -p "$(dirname "$logind_dropin")" 2>>"$ERROR_LOG_FILE" || true
if [[ ! -f "$logind_dropin" ]]; then
    printf "%s\n" "[Login]" "HandleLidSwitch=suspend" "HandleLidSwitchExternalPower=suspend" "HandleLidSwitchDocked=ignore" >"$logind_dropin"
fi
if [[ "$RESTART_LOGIND" == 1 ]]; then
    systemctl try-restart systemd-logind.service 2>>"$ERROR_LOG_FILE" || true
fi
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
