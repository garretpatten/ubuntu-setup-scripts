#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
pip3 install --user semgrep 2>>"$ERROR_LOG_FILE" || true
