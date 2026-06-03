#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
if [[ ! -f "$HOME/.gitconfig" ]]; then
    git config --global credential.helper store 2>>"$ERROR_LOG_FILE" || true
    git config --global http.postBuffer 157286400 2>>"$ERROR_LOG_FILE" || true
    git config --global pack.window 1 2>>"$ERROR_LOG_FILE" || true
    git config --global user.email "garret.patten@proton.me" 2>>"$ERROR_LOG_FILE" || true
    git config --global user.name "Garret Patten" 2>>"$ERROR_LOG_FILE" || true
    git config --global pull.rebase false 2>>"$ERROR_LOG_FILE" || true
    git config --global init.defaultBranch main 2>>"$ERROR_LOG_FILE" || true
fi
