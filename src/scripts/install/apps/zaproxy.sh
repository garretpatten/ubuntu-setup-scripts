#!/bin/bash

if command -v zaproxy >/dev/null 2>&1; then
    exit 0
fi
if snap list zaproxy 2>/dev/null | grep -q '^zaproxy '; then
    exit 0
fi

sudo systemctl start snapd.socket snapd.seeded.service 2>/dev/null || true
sudo snap install zaproxy --classic || true
