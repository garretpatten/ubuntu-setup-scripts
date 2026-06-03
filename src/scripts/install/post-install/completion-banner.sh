#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
ubuntu_art_file="$PROJECT_ROOT/src/assets/ubuntu.txt"
if [[ -f "$ubuntu_art_file" ]]; then
    echo
    echo "============================================================================"
    cat "$ubuntu_art_file" 2>/dev/null || true
    echo "============================================================================"
    echo
fi
echo "Setup completed. Check $ERROR_LOG_FILE for any errors."
