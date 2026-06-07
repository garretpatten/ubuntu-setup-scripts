#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/env.sh
source "$DIR/../lib/env.sh"
# shellcheck source=../lib/dotfiles-install.sh
source "$DIR/../lib/dotfiles-install.sh"

bash "$PROJECT_ROOT/src/dotfiles/setup.sh" --link-xdg-config
install_dotfiles_from_manifest "$DIR/dotfiles.manifest"
