#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
packages_file="$DIR/cli.packages"

mapfile -t packages < <(grep -v '^#' "$packages_file" | grep -v '^[[:space:]]*$')
if [[ ${#packages[@]} -eq 0 ]]; then
    exit 0
fi

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
