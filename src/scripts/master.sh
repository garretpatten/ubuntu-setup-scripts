#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/utils.sh"

bash "$SCRIPT_DIR/pre-install.sh" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute pre-install.sh"
bash "$SCRIPT_DIR/organizeHome.sh" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute organizeHome.sh"
bash "$SCRIPT_DIR/system-config.sh" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute system-config.sh"
bash "$SCRIPT_DIR/cli.sh" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute cli.sh"
bash "$SCRIPT_DIR/dev.sh" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute dev.sh"
bash "$SCRIPT_DIR/media.sh" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute media.sh"
bash "$SCRIPT_DIR/productivity.sh" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute productivity.sh"
bash "$SCRIPT_DIR/security.sh" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute security.sh"
bash "$SCRIPT_DIR/shell.sh" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute shell.sh"
bash "$SCRIPT_DIR/post-install.sh" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute post-install.sh"
