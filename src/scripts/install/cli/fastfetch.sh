#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch || true
sudo apt-get update -y || true

mapfile -t packages < <(grep -v '^#' "$DIR/fastfetch.packages" | grep -v '^[[:space:]]*$')
if [[ ${#packages[@]} -gt 0 ]]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
fi
