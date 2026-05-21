#!/bin/bash

# Firewall policy (runs after packages from install/security.sh).

# shellcheck source=../utils.sh
source "$(dirname "$0")/../utils.sh"

if ! command -v ufw >/dev/null 2>&1; then
    exit 0
fi

sudo ufw --force reset 2>>"$ERROR_LOG_FILE" || true
sudo ufw default deny incoming 2>>"$ERROR_LOG_FILE" || true
sudo ufw default allow outgoing 2>>"$ERROR_LOG_FILE" || true
sudo ufw allow ssh 2>>"$ERROR_LOG_FILE" || true
sudo ufw --force enable 2>>"$ERROR_LOG_FILE" || true
