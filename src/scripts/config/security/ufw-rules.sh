#!/bin/bash

command -v ufw >/dev/null 2>&1 || exit 0
sudo ufw --force reset || true
sudo ufw default deny incoming || true
sudo ufw default allow outgoing || true
sudo ufw allow ssh || true
sudo ufw --force enable || true
