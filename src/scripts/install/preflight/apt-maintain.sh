#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
update_apt_cache
sudo NEEDRESTART_MODE=l apt-get upgrade -y 2>>"$ERROR_LOG_FILE" || true
sudo apt-get autoremove -y 2>>"$ERROR_LOG_FILE" || true
sudo apt-get autoclean 2>>"$ERROR_LOG_FILE" || true
