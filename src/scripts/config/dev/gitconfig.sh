#!/bin/bash

[[ -f "$HOME/.gitconfig" ]] && exit 0
git config --global credential.helper store
git config --global http.postBuffer 157286400
git config --global pack.window 1
git config --global user.email "garret.patten@proton.me"
git config --global user.name "Garret Patten"
git config --global pull.rebase false
git config --global init.defaultBranch main
