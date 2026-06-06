#!/bin/bash
# Proton Pass desktop .deb — canonical URLs live in version.json (linked from
# https://www.proton.me/support/set-up-proton-pass-linux). Legacy ProtonPass.deb
# URLs often redirect or no longer serve the package bytes reliably.
proton_pass_deb="$TEMP_DIR/proton-pass.deb"
proton_pass_version_json_urls=(
    "https://proton.me/download/pass/linux/version.json"
    "https://proton.me/download/PassDesktop/linux/x64/version.json"
    "https://www.proton.me/download/PassDesktop/linux/x64/version.json"
)

proton_pass_is_valid_deb() {
    local candidate="$1"
    [[ -s "$candidate" ]] || return 1
    if command -v dpkg-deb >/dev/null 2>&1 && dpkg-deb -I "$candidate" >/dev/null 2>&1; then
        return 0
    fi
    # Fallback when dpkg-deb is unavailable: Debian packages are usually ar(5) archives.
    [[ "$(head -c 8 "$candidate" 2>/dev/null | tr -d '\0')" == $'!<arch>\n' ]] || \
        [[ "$(head -c 7 "$candidate" 2>/dev/null | tr -d '\0')" == '!<arch>' ]]
}

proton_pass_resolve_latest_stable_deb_url() {
    local json_path="$TEMP_DIR/proton-pass-version.json"
    local base_url deb_url=""
    for base_url in "${proton_pass_version_json_urls[@]}"; do
        rm -f "$json_path" 2>/dev/null || true
        if ! curl -fsSL --connect-timeout 30 --max-time 120 --retry 3 --retry-delay 2 \
            -A "Mozilla/5.0 (X11; Linux x86_64)" \
            "$base_url" -o "$json_path" ; then
            continue
        fi
        [[ -s "$json_path" ]] || continue
        if command -v python3 >/dev/null 2>&1; then
            deb_url=$(python3 -c '
import json, sys
path = sys.argv[1]
with open(path, encoding="utf-8") as fp:
    data = json.load(fp)
for rel in data.get("Releases", []):
    if rel.get("CategoryName") != "Stable":
        continue
    for item in rel.get("File", []):
        url = (item.get("Url") or "").strip()
        if not url.endswith(".deb"):
            continue
        ident = item.get("Identifier") or ""
        if ".deb" in ident.lower():
            print(url)
            sys.exit(0)
sys.exit(1)
' "$json_path" ) || deb_url=""
            [[ -n "$deb_url" ]] && printf '%s' "$deb_url" && return 0
        fi
    done
    return 1
}

proton_pass_urls=()
if resolved=$(proton_pass_resolve_latest_stable_deb_url); then
    proton_pass_urls+=("$resolved")
fi
proton_pass_urls+=(
    "https://proton.me/download/PassDesktop/linux/x64/ProtonPass.deb"
    "https://www.proton.me/download/PassDesktop/linux/x64/ProtonPass.deb"
)

proton_pass_downloaded=0
for proton_pass_url in "${proton_pass_urls[@]}"; do
    [[ -n "$proton_pass_url" ]] || continue
    rm -f "$proton_pass_deb" 2>/dev/null || true
    if curl -fsSL --connect-timeout 30 --max-time 600 --retry 3 --retry-delay 2 --retry-all-errors \
        -A "Mozilla/5.0 (X11; Linux x86_64)" \
        "$proton_pass_url" -o "$proton_pass_deb"  && proton_pass_is_valid_deb "$proton_pass_deb"; then
        proton_pass_downloaded=1
        break
    fi
done

if [[ "$proton_pass_downloaded" -eq 1 ]]; then
    sudo dpkg -i "$proton_pass_deb"  || true
    sudo apt-get install -f -y  || true
else
    echo "Failed to download Proton Pass .deb" >&2
fi

if ! command -v pass-cli >/dev/null 2>&1; then
    proton_pass_cli="$TEMP_DIR/pass-cli"
    proton_pass_cli_arch="x86_64"
    case "$(uname -m)" in
        aarch64 | arm64) proton_pass_cli_arch="aarch64" ;;
    esac
    proton_pass_cli_url="https://github.com/protonpass/pass-cli/releases/latest/download/pass-cli-linux-${proton_pass_cli_arch}"
    if curl -fsSL --retry 3 --retry-delay 2 "$proton_pass_cli_url" -o "$proton_pass_cli"; then
        chmod +x "$proton_pass_cli"
        sudo install -m 755 "$proton_pass_cli" /usr/local/bin/pass-cli
    fi
fi
