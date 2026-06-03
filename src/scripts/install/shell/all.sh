#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../utils.sh
source "$DIR/../../utils.sh"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"

run_script "$DIR/shell-apt.sh"
run_script "$DIR/ghostty.sh"
run_script "$DIR/fonts-apt.sh"
run_script "$DIR/meslo-nerd-font.sh"
run_script "$DIR/zsh-plugins.sh"
run_script "$DIR/oh-my-posh.sh"
