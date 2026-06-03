#!/bin/bash

# Package installs only — sources each category in order (Omarchy-style).

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../utils.sh
source "$DIR/../utils.sh"
# shellcheck source=../lib/run.sh
source "$DIR/../lib/run.sh"

run_script "$DIR/preflight/all.sh"
run_script "$DIR/cli/all.sh"
run_script "$DIR/media/all.sh"
run_script "$DIR/productivity/all.sh"
run_script "$DIR/dev/all.sh"
run_script "$DIR/security/all.sh"
run_script "$DIR/shell/all.sh"
run_script "$DIR/post-install/all.sh"
