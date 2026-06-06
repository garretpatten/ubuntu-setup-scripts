#!/bin/bash
# Package installation is orchestrated by install/all.sh (consolidated apt batch).

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/../all.sh"
