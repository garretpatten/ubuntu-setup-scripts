#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/apt-packages.sh
source "$DIR/../lib/apt-packages.sh"

sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch || true
sudo apt-get update -y || true
install_apt_packages_from_file "$DIR/packages/fastfetch.packages"
