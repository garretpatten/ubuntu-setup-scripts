#!/bin/bash

src="$PROJECT_ROOT/src/dotfiles/config/alacritty"
dest="$HOME/.config/alacritty"
[[ -d "$dest" ]] && exit 0
mkdir -p "$(dirname "$dest")"
cp -r "$src" "$dest"
