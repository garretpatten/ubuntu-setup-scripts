#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/apt-maintain.sh"
run_script "$DIR/docker-service.sh"
run_script "$DIR/tldr-cache.sh"
run_script "$DIR/completion-banner.sh"
