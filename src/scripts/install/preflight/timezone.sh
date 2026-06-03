#!/bin/bash
if [[ "$(timedatectl show --property=Timezone --value)" == "UTC" ]]; then
    sudo timedatectl set-timezone America/New_York || true
fi
