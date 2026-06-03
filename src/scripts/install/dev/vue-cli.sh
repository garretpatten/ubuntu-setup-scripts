#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
sudo npm install -g @vue/cli --loglevel=error --no-update-notifier 2>>"$ERROR_LOG_FILE" || true
