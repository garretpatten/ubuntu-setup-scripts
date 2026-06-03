#!/bin/bash

src="$PROJECT_ROOT/src/dotfiles/config/fastfetch"
dest="$HOME/.config/fastfetch"
[[ -d "$dest" ]] && exit 0
mkdir -p "$(dirname "$dest")"
cp -r "$src" "$dest"
