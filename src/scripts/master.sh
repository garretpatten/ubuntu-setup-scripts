#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

bash "$SCRIPT_DIR/pre-install.sh" || log_error "Failed to execute pre-install.sh"
bash "$SCRIPT_DIR/organizeHome.sh" || log_error "Failed to execute organizeHome.sh"
bash "$SCRIPT_DIR/cli.sh" || log_error "Failed to execute cli.sh"
bash "$SCRIPT_DIR/dev.sh" || log_error "Failed to execute dev.sh"
bash "$SCRIPT_DIR/media.sh" || log_error "Failed to execute media.sh"
bash "$SCRIPT_DIR/productivity.sh" || log_error "Failed to execute productivity.sh"
bash "$SCRIPT_DIR/security.sh" || log_error "Failed to execute security.sh"
bash "$SCRIPT_DIR/shell.sh" || log_error "Failed to execute shell.sh"
bash "$SCRIPT_DIR/post-install.sh" || log_error "Failed to execute post-install.sh"
