#!/bin/bash

credential_helper="/usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret"
if [[ -x "$credential_helper" ]]; then
    git config --global credential.helper "$credential_helper"
fi

# Shared Git pre-commit hook (symlinked by config/dotfiles.sh)
if ! git config --global core.hooksPath >/dev/null 2>&1; then
    git config --global core.hooksPath "$HOME/.config/githooks"
fi

if [[ -f "$HOME/.gitconfig" ]]; then
    exit 0
fi

git config --global http.postBuffer 157286400
git config --global pack.window 1
git config --global user.email "garret.patten@proton.me"
git config --global user.name "Garret Patten"
git config --global pull.rebase false
git config --global init.defaultBranch main
