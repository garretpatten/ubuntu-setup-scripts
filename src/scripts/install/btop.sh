#!/bin/bash

if command -v btop >/dev/null 2>&1; then
    exit 0
fi

btop_asset=""
case "$(uname -m)" in
    x86_64 | amd64) btop_asset="btop-x86_64-unknown-linux-musl.tar.gz" ;;
    aarch64 | arm64) btop_asset="btop-aarch64-unknown-linux-musl.tar.gz" ;;
esac

if [[ -n "$btop_asset" ]]; then
    btop_tag=$(curl -s https://api.github.com/repos/aristocratos/btop/releases/latest | grep '"tag_name"' | head -1 | cut -d '"' -f 4)
    if [[ -n "$btop_tag" ]]; then
        btop_tgz="$TEMP_DIR/$btop_asset"
        btop_url="https://github.com/aristocratos/btop/releases/download/${btop_tag}/${btop_asset}"
        if curl -fsSL "$btop_url" -o "$btop_tgz"; then
            mkdir -p "$HOME/.local/bin"
            tar -xzf "$btop_tgz" -C "$TEMP_DIR" || true
            if [[ -f "$TEMP_DIR/btop" ]]; then
                install -m 755 "$TEMP_DIR/btop" "$HOME/.local/bin/btop" || true
            fi
        fi
    fi
fi
if command -v btop >/dev/null 2>&1; then
    exit 0
fi

if command -v snap >/dev/null 2>&1; then
    sudo snap install btop || true
fi
