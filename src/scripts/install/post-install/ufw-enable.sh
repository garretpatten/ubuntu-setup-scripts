#!/bin/bash

command -v ufw >/dev/null 2>&1 && sudo ufw --force enable || true
