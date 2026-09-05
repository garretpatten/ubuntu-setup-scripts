#!/usr/bin/env bash
# Verify config outcomes after a standalone run-config.sh (no install).
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

# shellcheck source=lib/validate-common.sh
source "$(dirname "$0")/lib/validate-common.sh"
# shellcheck source=lib/validate-config-sections.sh
source "$(dirname "$0")/lib/validate-config-sections.sh"

validate_config_dotfiles
validate_config_home

section 'System'
validate_config_system_core
# UFW is skipped in config-only runs because ufw is installed by the install scripts.

# Git credential helper is skipped: it depends on install/dev/git-credential-libsecret.sh.

finish_validation 'Config-only validation'
