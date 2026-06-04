#!/bin/bash

command -v docker >/dev/null 2>&1 || exit 0
sudo systemctl enable docker.service || true
sudo systemctl start docker.service || true
sudo usermod -aG docker "$USER" || true
