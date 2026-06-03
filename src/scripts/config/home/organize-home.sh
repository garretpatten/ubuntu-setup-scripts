#!/bin/bash

rmdir "$HOME/Music" 2>/dev/null || true
rmdir "$HOME/Public" 2>/dev/null || true
rmdir "$HOME/Templates" 2>/dev/null || true
mkdir -p "$HOME/AppImages" "$HOME/Hacking" "$HOME/Projects/opensource" "$HOME/Projects/personal"
[[ -d "$HOME/Scripts" ]] && chmod 755 "$HOME/Scripts" || true
[[ -d "$HOME/Hacking" ]] && chmod 700 "$HOME/Hacking" || true
