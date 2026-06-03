#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
if [[ "$(timedatectl show --property=Timezone --value)" == "UTC" ]]; then
    sudo timedatectl set-timezone America/New_York 2>>"$ERROR_LOG_FILE" || true
fi
