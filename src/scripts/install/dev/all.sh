#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/nodesource-nodejs.sh"
run_script "$DIR/nvm.sh"
run_script "$DIR/python.sh"
run_script "$DIR/vue-cli.sh"
run_script "$DIR/docker.sh"
run_script "$DIR/neovim.sh"
run_script "$DIR/dev-tools-apt.sh"
run_script "$DIR/postman.sh"
run_script "$DIR/semgrep.sh"
run_script "$DIR/sourcegraph-cli.sh"
