#!/bin/bash

if command -v ufw >/dev/null 2>&1; then
    sudo ufw --force enable || true
fi
