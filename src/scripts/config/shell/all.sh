#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/env.sh
source "$DIR/../../lib/env.sh"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/dotfiles-zshrc.sh"
run_script "$DIR/chsh-zsh.sh"
