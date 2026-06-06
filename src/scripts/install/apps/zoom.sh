#!/bin/bash

if command -v zoom >/dev/null 2>&1; then
    exit 0
fi

zoom_deb="$TEMP_DIR/zoom_amd64.deb"
curl -fsSL https://zoom.us/client/latest/zoom_amd64.deb -o "$zoom_deb" || true
