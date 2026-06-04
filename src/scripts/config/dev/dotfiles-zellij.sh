#!/bin/bash

src="$PROJECT_ROOT/src/dotfiles/config/zellij"
dest="$HOME/.config/zellij"
[[ -d "$dest" ]] && exit 0
mkdir -p "$(dirname "$dest")"
cp -r "$src" "$dest"
