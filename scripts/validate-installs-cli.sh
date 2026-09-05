#!/usr/bin/env bash
# Verify tools and apps installed by src/scripts/install/* after run-install.sh cli.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

export PATH="${HOME}/.cargo/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}"

# shellcheck source=lib/validate-common.sh
source "$(dirname "$0")/lib/validate-common.sh"
# shellcheck source=lib/validate-installs-sections.sh
source "$(dirname "$0")/lib/validate-installs-sections.sh"

validate_preflight
validate_cli_packages
validate_nvm
validate_dev
validate_security_cli
validate_pass_cli
validate_shell

finish_validation 'CLI install validation'
