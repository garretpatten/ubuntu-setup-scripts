#!/bin/bash

if command -v snap >/dev/null 2>&1; then
    sudo snap install zaproxy --classic || true
fi
