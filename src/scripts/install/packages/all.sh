#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/run.sh
source "$DIR/../../lib/run.sh"
# shellcheck source=../../lib/apt-packages.sh
source "$DIR/../../lib/apt-packages.sh"

for list in base shell media desktop productivity; do
    install_apt_packages_from_file "$DIR/${list}.packages"
done

echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-restricted-extras || true

run_script "$DIR/../griffo.sh"
run_script "$DIR/../fastfetch.sh"
run_script "$DIR/../btop.sh"
run_script "$DIR/../flatpak.sh"
