#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/env.sh
source "$DIR/lib/env.sh"
# shellcheck source=lib/run.sh
source "$DIR/lib/run.sh"
# shellcheck source=lib/zsh-login.sh
source "$DIR/lib/zsh-login.sh"

ensure_zshrc_login_safe

run_script "$DIR/install/preflight/all.sh"
run_script "$DIR/config/system/all.sh"
run_script "$DIR/config/home/all.sh"
run_script "$DIR/install/cli/all.sh"
run_script "$DIR/install/media/all.sh"
run_script "$DIR/install/productivity/all.sh"
run_script "$DIR/install/dev/all.sh"
run_script "$DIR/config/dev/all.sh"
run_script "$DIR/install/security/all.sh"
run_script "$DIR/config/security/all.sh"
run_script "$DIR/install/shell/all.sh"
run_script "$DIR/install/post-install/all.sh"
run_script "$DIR/config/shell/all.sh"
