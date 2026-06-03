#!/bin/bash

src="$PROJECT_ROOT/src/dotfiles/config/btop"
dest="$HOME/.config/btop"
[[ -d "$dest" ]] && exit 0
mkdir -p "$(dirname "$dest")"
cp -r "$src" "$dest"
