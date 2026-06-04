#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/env.sh
source "$DIR/../lib/env.sh"
# shellcheck source=../lib/run.sh
source "$DIR/../lib/run.sh"

run_script "$DIR/system/all.sh"
run_script "$DIR/home/all.sh"
run_script "$DIR/dev/all.sh"
run_script "$DIR/security/all.sh"
run_script "$DIR/shell/all.sh"
