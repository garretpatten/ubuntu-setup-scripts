#!/bin/bash

command -v tldr >/dev/null 2>&1 || exit 0
tldr -L en --update || true
