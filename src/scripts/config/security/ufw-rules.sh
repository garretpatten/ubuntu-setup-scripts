#!/bin/bash

command -v ufw >/dev/null 2>&1 || exit 0

# Allow nothing in, everything out
sudo ufw default deny incoming || true
sudo ufw default allow outgoing || true

# Allow ports for LocalSend
sudo ufw allow 53317/udp || true
sudo ufw allow 53317/tcp || true

# Allow Docker containers to use DNS on host
sudo ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns' || true
sudo ufw allow in proto udp from 192.168.0.0/16 to 172.17.0.1 port 53 comment 'allow-docker-dns' || true

# Turn on the firewall
sudo ufw --force enable || true

# Enable UFW systemd service to start on boot
sudo systemctl enable ufw || true

# Turn on Docker protections
if command -v ufw-docker >/dev/null 2>&1; then
    sudo ufw-docker install || true
    sudo ufw reload || true
fi
