#!/bin/bash

font_dir="/usr/share/fonts/meslo-nerd-font"
[[ -d "$font_dir" ]] && exit 0
temp_font_dir="$TEMP_DIR/meslo-font"
mkdir -p "$temp_font_dir"
meslo_zip="$temp_font_dir/Meslo.zip"
curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip -o "$meslo_zip" || exit 0
sudo mkdir -p "$font_dir"
unzip -q "$meslo_zip" -d "$temp_font_dir" || true
sudo mv "$temp_font_dir"/*.ttf "$font_dir/" 2>/dev/null || true
sudo mv "$temp_font_dir"/*.otf "$font_dir/" 2>/dev/null || true
fc-cache -fv || true
