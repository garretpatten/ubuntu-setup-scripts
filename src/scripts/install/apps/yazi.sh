#!/bin/bash
# yazi file manager and ya companion binaries from the official GitHub releases.

if ! command -v yazi >/dev/null 2>&1; then
    yazi_arch="x86_64-unknown-linux-gnu"
    case "$(uname -m)" in
        aarch64 | arm64) yazi_arch="aarch64-unknown-linux-gnu" ;;
    esac
    yazi_zip="$TEMP_DIR/yazi.zip"
    if curl -fsSL --retry 3 --retry-delay 2 \
        "https://github.com/sxyazi/yazi/releases/latest/download/yazi-$yazi_arch.zip" \
        -o "$yazi_zip" && [[ -s "$yazi_zip" ]]; then
        unzip -q -o "$yazi_zip" "yazi-$yazi_arch/yazi" "yazi-$yazi_arch/ya" -d "$TEMP_DIR"
        sudo install -m 755 "$TEMP_DIR/yazi-$yazi_arch/yazi" /usr/local/bin/yazi
        sudo install -m 755 "$TEMP_DIR/yazi-$yazi_arch/ya" /usr/local/bin/ya
    fi
fi
