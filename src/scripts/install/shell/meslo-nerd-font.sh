#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
font_dir="/usr/share/fonts/meslo-nerd-font"
if [[ ! -d "$font_dir" ]]; then
    temp_font_dir="$TEMP_DIR/meslo-font"
    ensure_directory "$temp_font_dir"
    meslo_zip="$temp_font_dir/Meslo.zip"
    download_file_safe "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip" "$meslo_zip"
    if [[ -f "$meslo_zip" ]]; then
        sudo mkdir -p "$font_dir" 2>>"$ERROR_LOG_FILE" || true
        unzip -q "$meslo_zip" -d "$temp_font_dir" 2>>"$ERROR_LOG_FILE" || true
        sudo mv "$temp_font_dir"/*.ttf "$font_dir/" 2>>"$ERROR_LOG_FILE" || true
        if ls "$temp_font_dir"/*.otf 1>/dev/null 2>&1; then
            sudo mv "$temp_font_dir"/*.otf "$font_dir/" 2>>"$ERROR_LOG_FILE" || true
        fi
        if ls "$font_dir"/*.ttf 1>/dev/null 2>&1; then
            sudo chmod 644 "$font_dir"/*.ttf 2>>"$ERROR_LOG_FILE" || true
        fi
        if ls "$font_dir"/*.otf 1>/dev/null 2>&1; then
            sudo chmod 644 "$font_dir"/*.otf 2>>"$ERROR_LOG_FILE" || true
        fi
    fi
fi
fc-cache -fv 2>>"$ERROR_LOG_FILE" || true
