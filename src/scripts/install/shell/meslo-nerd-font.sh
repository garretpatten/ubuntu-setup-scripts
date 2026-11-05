#!/bin/bash
# Meslo Nerd Font from the nerd-fonts GitHub release.
# A failed download exits non-zero so orchestrators surface the failure.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/download.sh
source "$DIR/../../lib/download.sh"

font_dir="/usr/share/fonts/meslo-nerd-font"
[[ -d "$font_dir" ]] && exit 0

if [[ -z "${TEMP_DIR:-}" ]]; then
    echo 'ERROR: TEMP_DIR is not set; run via an orchestrator' >&2
    exit 1
fi

temp_font_dir="$TEMP_DIR/meslo-font"
mkdir -p "$temp_font_dir"
meslo_zip="$temp_font_dir/Meslo.zip"
if ! download_installer \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip \
    "$meslo_zip"; then
    echo 'WARNING: Meslo font download failed' >&2
    exit 1
fi

sudo mkdir -p "$font_dir"
unzip -q "$meslo_zip" -d "$temp_font_dir" || true
sudo mv "$temp_font_dir"/*.ttf "$font_dir/" 2>/dev/null || true
sudo mv "$temp_font_dir"/*.otf "$font_dir/" 2>/dev/null || true
fc-cache -fv || true
