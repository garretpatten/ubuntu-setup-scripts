#!/bin/bash

# Full provisioning: interleaved installs and configuration — same chronological
# idea as sibling macOS-setup-scripts (`master.sh`): defaults and home layout
# early; dev dotfiles immediately after development packages; shell dotfiles
# after apt maintenance/post-install hooks.

# shellcheck source=utils.sh
source "$(dirname "$0")/utils.sh"

ROOT="$(dirname "$0")"
IDIR="$ROOT/install"
CDIR="$ROOT/config"

run() {
    bash "$1" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute $1"
}

run "$IDIR/pre-install.sh"

run "$CDIR/system-config.sh"
run "$CDIR/organizeHome.sh"

run "$IDIR/cli.sh"
run "$IDIR/media.sh"
run "$IDIR/productivity.sh"

run "$IDIR/dev.sh"
run "$CDIR/dev.sh"

run "$IDIR/security.sh"
run "$CDIR/security.sh"

run "$IDIR/shell.sh"

run "$IDIR/post-install.sh"

run "$CDIR/shell.sh"
