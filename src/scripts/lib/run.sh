#!/bin/bash

# Run a setup script; errors append to ERROR_LOG_FILE (requires utils.sh).

run_script() {
    bash "$1" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute $1"
}

export -f run_script
