#!/bin/bash

# GNOME/session defaults, home layout, UFW defaults, submodule dotfiles, shell.

# shellcheck source=utils.sh
source "$(dirname "$0")/utils.sh"
# shellcheck source=lib/run.sh
source "$(dirname "$0")/lib/run.sh"

ensure_zshrc_login_safe

run_script "$(dirname "$0")/config/all.sh"
