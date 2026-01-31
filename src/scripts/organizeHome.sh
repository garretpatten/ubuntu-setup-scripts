#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

remove_empty_directory "$HOME/Music"
remove_empty_directory "$HOME/Public"
remove_empty_directory "$HOME/Templates"

ensure_directory "$HOME/AppImages"
ensure_directory "$HOME/Hacking"
ensure_directory "$HOME/Projects"
ensure_directory "$HOME/Scripts"
ensure_directory "$HOME/Tools"

ensure_directory "$HOME/Projects/personal"
ensure_directory "$HOME/Projects/work"
ensure_directory "$HOME/Projects/learning"
ensure_directory "$HOME/Projects/opensource"
ensure_directory "$HOME/Scripts/automation"
ensure_directory "$HOME/Scripts/utilities"
ensure_directory "$HOME/Scripts/backup"

if [[ -d "$HOME/Desktop" ]]; then
    ln -sf "$HOME/Projects" "$HOME/Desktop/Projects" 2>/dev/null || true
fi
ln -sf "$HOME/Downloads" "$HOME/Projects/downloads" 2>/dev/null || true

chmod 755 "$HOME/Scripts" 2>/dev/null || true
chmod 700 "$HOME/Hacking" 2>/dev/null || true
