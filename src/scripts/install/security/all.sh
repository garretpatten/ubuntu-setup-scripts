#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/defense-apt.sh"
run_script "$DIR/ufw-docker.sh"
run_script "$DIR/protonvpn.sh"
run_script "$DIR/proton-pass.sh"
run_script "$DIR/signal-desktop.sh"
run_script "$DIR/security-tools-apt.sh"
run_script "$DIR/zaproxy.sh"
run_script "$DIR/hacking-repos.sh"
