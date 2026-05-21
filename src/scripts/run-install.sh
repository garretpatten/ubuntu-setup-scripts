#!/bin/bash

# APT, Flatpak, external installers (no GNOME defaults or dotfiles).

# shellcheck source=utils.sh
source "$(dirname "$0")/utils.sh"

IDIR="$SCRIPTS_DIR/install"

run_install() {
    bash "$1" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute $1"
}

run_install "$IDIR/pre-install.sh"
run_install "$IDIR/cli.sh"
run_install "$IDIR/media.sh"
run_install "$IDIR/productivity.sh"
run_install "$IDIR/dev.sh"
run_install "$IDIR/security.sh"
run_install "$IDIR/shell.sh"
run_install "$IDIR/post-install.sh"
