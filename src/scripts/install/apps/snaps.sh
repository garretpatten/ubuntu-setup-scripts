#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/snap-install.sh
source "$DIR/../../lib/snap-install.sh"

install_snaps_from_file "$DIR/../snaps.txt"
