#!/bin/bash
# 7-day apt supply-chain cooldown from dotfiles system/apt-cooldown/.
# Holds apt on the official Ubuntu archive as it was 7 days ago via
# snapshot.ubuntu.com, so apt / unattended-upgrades never see packages younger
# than the cooldown. Requires Ubuntu 24.04+ apt (snapshot auto-detection).

apt_os_version="$(. /etc/os-release && printf '%s' "$VERSION_ID")"
if [[ "$apt_os_version" != 24.04 && "$apt_os_version" != 26.04 ]]; then
    exit 0
fi

cooldown_src="$PROJECT_ROOT/src/dotfiles/system/apt-cooldown"
[[ -d "$cooldown_src" ]] || exit 1

sudo install -m 755 "$cooldown_src/apt-cooldown-snapshot" /usr/local/sbin/
sudo install -m 644 "$cooldown_src/apt-cooldown-snapshot.service" /etc/systemd/system/
sudo install -m 644 "$cooldown_src/apt-cooldown-snapshot.timer" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now apt-cooldown-snapshot.timer
