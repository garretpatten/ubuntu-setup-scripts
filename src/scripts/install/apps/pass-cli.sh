#!/bin/bash
# Proton Pass CLI binary.
# A failed download exits non-zero so orchestrators surface the failure.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/download.sh
source "$DIR/../../lib/download.sh"

if command -v pass-cli >/dev/null 2>&1; then
    exit 0
fi

if [[ -z "${TEMP_DIR:-}" ]]; then
    echo 'ERROR: TEMP_DIR is not set; run via an orchestrator' >&2
    exit 1
fi

proton_pass_cli="$TEMP_DIR/pass-cli"
proton_pass_cli_arch="x86_64"
case "$(uname -m)" in
    aarch64 | arm64) proton_pass_cli_arch="aarch64" ;;
esac
proton_pass_cli_url="https://github.com/protonpass/pass-cli/releases/latest/download/pass-cli-linux-${proton_pass_cli_arch}"
if ! download_installer "$proton_pass_cli_url" "$proton_pass_cli"; then
    echo 'WARNING: pass-cli download failed' >&2
    exit 1
fi
if [[ "$(head -c 4 "$proton_pass_cli" 2>/dev/null)" != $'\x7fELF' ]]; then
    echo 'ERROR: pass-cli download is not an ELF binary' >&2
    exit 1
fi
chmod +x "$proton_pass_cli"
sudo install -m 755 "$proton_pass_cli" /usr/local/bin/pass-cli
