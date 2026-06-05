#!/bin/bash

command -v ollama >/dev/null 2>&1 && exit 0
curl -fsSL https://ollama.com/install.sh | sh || true
