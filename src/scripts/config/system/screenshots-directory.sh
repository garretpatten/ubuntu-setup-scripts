#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
if [[ "$OSTYPE" != linux-gnu* ]]; then
    log_error "system config targets Linux (Ubuntu)"
    exit 1
fi
ensure_directory "$HOME/Pictures/Screenshots"
