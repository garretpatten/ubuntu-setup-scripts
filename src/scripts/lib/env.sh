#!/bin/bash

# Exports used by orchestrators and leaf scripts (sourced once per run).

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PROJECT_ROOT="$(cd "$SCRIPTS_DIR/../.." && pwd)"
export ERROR_LOG_FILE="${PROJECT_ROOT}/setup_errors.log"
export TEMP_DIR="/tmp/ubuntu-setup-$$"
mkdir -p "$TEMP_DIR"
