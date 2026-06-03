#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/brave-browser.sh"
run_script "$DIR/vlc.sh"
run_script "$DIR/spotify.sh"
run_script "$DIR/multimedia.sh"
