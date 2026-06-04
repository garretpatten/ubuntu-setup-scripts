#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/flatpak.sh"
run_script "$DIR/cli-tools.sh"
run_script "$DIR/yazi.sh"
run_script "$DIR/btop.sh"
run_script "$DIR/fastfetch.sh"
