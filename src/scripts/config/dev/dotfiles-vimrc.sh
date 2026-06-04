#!/bin/bash

src="$PROJECT_ROOT/src/dotfiles/home/.vimrc"
[[ -f "$HOME/.vimrc" ]] || cp "$src" "$HOME/.vimrc"
