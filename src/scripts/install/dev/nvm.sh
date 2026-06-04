#!/bin/bash
[[ -d "$HOME/.nvm" ]] && exit 0
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash || true
