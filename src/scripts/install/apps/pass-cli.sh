#!/bin/bash
# Proton Pass CLI binary.

if ! command -v pass-cli >/dev/null 2>&1; then
    proton_pass_cli="$TEMP_DIR/pass-cli"
    proton_pass_cli_arch="x86_64"
    case "$(uname -m)" in
        aarch64 | arm64) proton_pass_cli_arch="aarch64" ;;
    esac
    proton_pass_cli_url="https://github.com/protonpass/pass-cli/releases/latest/download/pass-cli-linux-${proton_pass_cli_arch}"
    if curl -fsSL --retry 3 --retry-delay 2 "$proton_pass_cli_url" -o "$proton_pass_cli"; then
        if [[ -s "$proton_pass_cli" ]] && [[ "$(head -c 4 "$proton_pass_cli" 2>/dev/null)" == $'\x7fELF' ]]; then
            chmod +x "$proton_pass_cli"
            sudo install -m 755 "$proton_pass_cli" /usr/local/bin/pass-cli
        fi
    fi
fi
