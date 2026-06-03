#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/libreoffice.sh"
run_script "$DIR/zoom.sh"
run_script "$DIR/standardnotes.sh"
run_script "$DIR/productivity-apt.sh"
run_script "$DIR/etcher.sh"
