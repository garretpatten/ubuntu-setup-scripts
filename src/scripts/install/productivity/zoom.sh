#!/bin/bash

if command -v snap >/dev/null 2>&1; then
    sudo snap install zoom-client || true
fi
