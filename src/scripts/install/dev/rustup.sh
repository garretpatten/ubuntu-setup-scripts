#!/bin/bash
[[ -f "$HOME/.cargo/env" ]] && exit 0
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || true
