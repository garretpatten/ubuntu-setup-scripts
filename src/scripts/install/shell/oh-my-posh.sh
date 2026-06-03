#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
omp_install_script="$TEMP_DIR/oh-my-posh-install.sh"
download_file_safe "https://ohmyposh.dev/install.sh" "$omp_install_script"
if [[ -f "$omp_install_script" ]]; then
    bash "$omp_install_script" -s -- --user 2>>"$ERROR_LOG_FILE" || true
fi
themes_dir="/usr/share/oh-my-posh/themes"
if [[ ! -d "$themes_dir" ]] || [[ -z "$(ls -A "$themes_dir" 2>/dev/null)" ]]; then
    sudo mkdir -p "$themes_dir" 2>>"$ERROR_LOG_FILE" || true
    temp_repo_dir="$TEMP_DIR/oh-my-posh-repo"
    clone_repository_safe "https://github.com/JanDeDobbeleer/oh-my-posh.git" "$temp_repo_dir"
    if [[ -d "$temp_repo_dir/themes" ]]; then
        sudo cp -r "$temp_repo_dir/themes/"* "$themes_dir/" 2>>"$ERROR_LOG_FILE" || true
        sudo chmod -R 755 "$themes_dir" 2>>"$ERROR_LOG_FILE" || true
        sudo chown -R root:root "$themes_dir" 2>>"$ERROR_LOG_FILE" || true
    fi
fi
