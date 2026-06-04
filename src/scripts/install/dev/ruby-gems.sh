#!/bin/bash
if ! command -v gem >/dev/null 2>&1; then
  exit 0
fi
gem install --user-install solargraph || true
