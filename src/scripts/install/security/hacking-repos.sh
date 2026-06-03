#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
ensure_directory "$HOME/Hacking"
clone_repository_safe "https://github.com/swisskyrepo/PayloadsAllTheThings" "$HOME/Hacking/PayloadsAllTheThings"
clone_repository_safe "https://github.com/danielmiessler/SecLists" "$HOME/Hacking/SecLists"
