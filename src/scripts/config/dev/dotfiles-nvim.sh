#!/bin/bash

src="$PROJECT_ROOT/src/dotfiles/config/nvim"
dest="$HOME/.config/nvim"
[[ -d "$dest" ]] && exit 0
mkdir -p "$(dirname "$dest")"
cp -r "$src" "$dest"
