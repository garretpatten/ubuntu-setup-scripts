#!/bin/bash

# Full provisioning: interleaved installs and configuration — same chronological
# idea as sibling macOS-setup-scripts (`master.sh`): defaults and home layout
# early; dev dotfiles immediately after development packages; shell dotfiles
# after apt maintenance/post-install hooks.

# shellcheck source=utils.sh
source "$(dirname "$0")/utils.sh"
# shellcheck source=lib/run.sh
source "$(dirname "$0")/lib/run.sh"

ROOT="$(dirname "$0")"
IDIR="$ROOT/install"
CDIR="$ROOT/config"

ensure_zshrc_login_safe

run_script "$IDIR/preflight/all.sh"

run_script "$CDIR/system/all.sh"
run_script "$CDIR/home/all.sh"

run_script "$IDIR/cli/all.sh"
run_script "$IDIR/media/all.sh"
run_script "$IDIR/productivity/all.sh"

run_script "$IDIR/dev/all.sh"
run_script "$CDIR/dev/all.sh"

run_script "$IDIR/security/all.sh"
run_script "$CDIR/security/all.sh"

run_script "$IDIR/shell/all.sh"

run_script "$IDIR/post-install/all.sh"

run_script "$CDIR/shell/all.sh"
