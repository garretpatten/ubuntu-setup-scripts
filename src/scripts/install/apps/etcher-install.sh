#!/bin/bash

if command -v balena-etcher >/dev/null 2>&1; then
    exit 0
fi

etcher_deb="$TEMP_DIR/balena-etcher.deb"
if [[ -f "$etcher_deb" ]]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$etcher_deb" || true
fi
