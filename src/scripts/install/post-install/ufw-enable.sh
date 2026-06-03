#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
if command -v ufw >/dev/null 2>&1; then
    sudo ufw --force enable 2>>"$ERROR_LOG_FILE" || true
fi
