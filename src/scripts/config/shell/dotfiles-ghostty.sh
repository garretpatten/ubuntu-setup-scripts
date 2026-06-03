#!/bin/bash

src="$PROJECT_ROOT/src/dotfiles/config/ghostty"
dest="$HOME/.config/ghostty"
[[ -d "$dest" ]] || { mkdir -p "$(dirname "$dest")"; cp -r "$src" "$dest"; }
