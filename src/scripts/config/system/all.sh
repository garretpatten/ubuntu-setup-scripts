#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/screenshots-directory.sh"
run_script "$DIR/gnome-gsettings.sh"
run_script "$DIR/unattended-upgrades.sh"
run_script "$DIR/system-policy.sh"
