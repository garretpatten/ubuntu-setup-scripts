#!/bin/bash

if command -v zoom >/dev/null 2>&1; then
    exit 0
fi

zoom_deb="$TEMP_DIR/zoom_amd64.deb"
if [[ -f "$zoom_deb" ]]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$zoom_deb" || true
fi
