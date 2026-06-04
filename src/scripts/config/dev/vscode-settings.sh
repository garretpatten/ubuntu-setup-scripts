#!/bin/bash

src="$PROJECT_ROOT/src/dotfiles/vs-code/settings.json"
dest="$HOME/.config/Code/User/settings.json"
[[ -f "$dest" ]] || { mkdir -p "$(dirname "$dest")"; cp "$src" "$dest"; }
