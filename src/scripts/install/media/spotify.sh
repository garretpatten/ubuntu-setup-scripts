#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
if command -v snap >/dev/null 2>&1; then
    sudo snap install spotify 2>>"$ERROR_LOG_FILE" || true
fi
