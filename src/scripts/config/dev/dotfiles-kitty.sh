#!/bin/bash

src="$PROJECT_ROOT/src/dotfiles/config/kitty"
dest="$HOME/.config/kitty"
[[ -d "$dest" ]] && exit 0
mkdir -p "$(dirname "$dest")"
cp -r "$src" "$dest"
