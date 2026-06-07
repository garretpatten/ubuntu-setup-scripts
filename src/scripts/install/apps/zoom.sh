#!/bin/bash

if command -v zoom >/dev/null 2>&1; then
    exit 0
fi
if snap list zoom-client 2>/dev/null | grep -q '^zoom-client '; then
    exit 0
fi

sudo systemctl start snapd.socket snapd.seeded.service 2>/dev/null || true
sudo snap install zoom-client || true
