#!/bin/bash
# Dev tool installation is orchestrated by install/all.sh.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/../all.sh"
