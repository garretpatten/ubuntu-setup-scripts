#!/bin/bash

# APT, Flatpak, external installers (no GNOME defaults or dotfiles).

# shellcheck source=utils.sh
source "$(dirname "$0")/utils.sh"
# shellcheck source=lib/run.sh
source "$(dirname "$0")/lib/run.sh"

run_script "$(dirname "$0")/install/all.sh"
