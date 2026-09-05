#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "$DIR/lib/env.sh"
# shellcheck source=lib/run.sh
source "$DIR/lib/run.sh"
# shellcheck source=lib/git-submodules.sh
source "$DIR/lib/git-submodules.sh"
# shellcheck source=lib/zsh-login.sh
source "$DIR/lib/zsh-login.sh"

ensure_submodules_synced "$PROJECT_ROOT"
ensure_zshrc_login_safe

run_script "$DIR/config/all.sh"
