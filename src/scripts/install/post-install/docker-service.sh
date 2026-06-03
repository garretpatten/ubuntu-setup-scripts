#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
if command -v docker >/dev/null 2>&1; then
    sudo systemctl enable docker.service 2>>"$ERROR_LOG_FILE" || true
    sudo systemctl start docker.service 2>>"$ERROR_LOG_FILE" || true
    sudo usermod -aG docker "$USER" 2>>"$ERROR_LOG_FILE" || true
fi
