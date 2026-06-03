#!/bin/bash
sg_binary="$TEMP_DIR/sg"
curl -fsSL https://sourcegraph.com/.api/src-cli/src_linux_amd64 -o "$sg_binary" || exit 0
chmod +x "$sg_binary"
sudo mv "$sg_binary" /usr/local/bin/sg || true
