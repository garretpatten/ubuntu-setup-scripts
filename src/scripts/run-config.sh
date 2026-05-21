#!/bin/bash

# GNOME/session defaults, home layout, UFW defaults, submodule dotfiles, shell.

# shellcheck source=utils.sh
source "$(dirname "$0")/utils.sh"

CDIR="$SCRIPTS_DIR/config"

run_config() {
    bash "$1" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute $1"
}

run_config "$CDIR/system-config.sh"
run_config "$CDIR/organizeHome.sh"
run_config "$CDIR/dev.sh"
run_config "$CDIR/security.sh"
run_config "$CDIR/shell.sh"
