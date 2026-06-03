#!/bin/bash

src="$PROJECT_ROOT/src/dotfiles/config/oh-my-posh"
dest="$HOME/.config/oh-my-posh"
[[ -d "$dest" ]] || { mkdir -p "$(dirname "$dest")"; cp -r "$src" "$dest"; }
