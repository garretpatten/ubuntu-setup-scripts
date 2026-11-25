#!/usr/bin/env bash
# Verify tools and apps installed by src/scripts/install/* after master.sh / run-install.sh all.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

export PATH="${HOME}/.cargo/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}"

# shellcheck source=lib/validate-common.sh
source "$(dirname "$0")/lib/validate-common.sh"
# shellcheck source=lib/validate-installs-sections.sh
source "$(dirname "$0")/lib/validate-installs-sections.sh"

validate_preflight
validate_cli_packages
validate_media
validate_productivity
validate_snaps
validate_deb_apps
validate_browsers
validate_nvm
validate_dev
validate_dev_desktop
validate_security_cli
validate_security_desktop
validate_pass_cli
validate_shell
validate_gnome

finish_validation 'Install validation'
