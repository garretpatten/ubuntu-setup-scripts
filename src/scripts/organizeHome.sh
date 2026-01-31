#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

remove_empty_directory "$HOME/Music"
remove_empty_directory "$HOME/Public"
remove_empty_directory "$HOME/Templates"

ensure_directory "$HOME/AppImages"
ensure_directory "$HOME/Hacking"
ensure_directory "$HOME/Projects"

ensure_directory "$HOME/Projects/opensource"
ensure_directory "$HOME/Projects/personal"

chmod 755 "$HOME/Scripts" 2>>"$ERROR_LOG_FILE" || true
chmod 700 "$HOME/Hacking" 2>>"$ERROR_LOG_FILE" || true
