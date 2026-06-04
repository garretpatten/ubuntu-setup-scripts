#!/usr/bin/env bash
# CI/local gate: installed tools and config outcomes after master.sh.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
export PATH="${HOME}/.cargo/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}"

failures=0
chmod +x scripts/validate-installs.sh scripts/validate-config.sh

./scripts/validate-installs.sh || failures=$((failures + 1))
./scripts/validate-config.sh || failures=$((failures + 1))

exit "$failures"
