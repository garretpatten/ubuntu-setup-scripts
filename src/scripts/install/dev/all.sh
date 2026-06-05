#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"
# shellcheck source=../../lib/apt-packages.sh
source "$DIR/../../lib/apt-packages.sh"

run_script "$DIR/neovim.sh"
run_script "$DIR/nodesource-nodejs.sh"
run_script "$DIR/nvm.sh"
install_apt_packages_from_file "$DIR/../packages/lsp.packages"
install_apt_packages_from_file "$DIR/../packages/lsp-optional.packages" optional
run_script "$DIR/git-credential-libsecret.sh"
install_apt_packages_from_file "$DIR/../packages/dev.packages"
run_script "$DIR/rustup.sh"
run_script "$DIR/ruby-gems.sh"
run_script "$DIR/docker.sh"
run_script "$DIR/vue-cli.sh"
run_script "$DIR/semgrep.sh"
run_script "$DIR/cursor-cli.sh"
run_script "$DIR/ollama.sh"
