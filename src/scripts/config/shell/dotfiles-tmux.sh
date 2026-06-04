#!/bin/bash

src="$PROJECT_ROOT/src/dotfiles/config/tmux"
dest="$HOME/.config/tmux"
[[ -d "$dest" ]] || { mkdir -p "$(dirname "$dest")"; cp -r "$src" "$dest"; }
