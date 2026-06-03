#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
ghostty_ubuntu_install_script="$TEMP_DIR/ghostty-ubuntu-install.sh"
if download_file_safe "https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh" "$ghostty_ubuntu_install_script"; then
    sudo /bin/bash "$ghostty_ubuntu_install_script" 2>>"$ERROR_LOG_FILE" || log_error "Ghostty Ubuntu install script failed"
fi
