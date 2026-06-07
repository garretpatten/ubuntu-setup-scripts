#!/bin/bash

auto_upgrades="/etc/apt/apt.conf.d/20auto-upgrades"
if [[ ! -f "$auto_upgrades" ]]; then
    sudo tee "$auto_upgrades" >/dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "1";
EOF
fi
