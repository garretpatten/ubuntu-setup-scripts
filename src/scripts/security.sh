#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

defense_tools=(
    "ufw"
    "openvpn"
)
install_apt_packages "${defense_tools[@]}"

sudo ufw --force reset 2>>"$ERROR_LOG_FILE" || true
sudo ufw default deny incoming 2>>"$ERROR_LOG_FILE" || true
sudo ufw default allow outgoing 2>>"$ERROR_LOG_FILE" || true
sudo ufw allow ssh 2>>"$ERROR_LOG_FILE" || true
sudo ufw --force enable 2>>"$ERROR_LOG_FILE" || true

protonvpn_deb="$TEMP_DIR/protonvpn-stable-release.deb"
download_file_safe "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb" "$protonvpn_deb"
if [[ -f "$protonvpn_deb" ]] && [[ -s "$protonvpn_deb" ]]; then
    if file "$protonvpn_deb" 2>/dev/null | grep -q "Debian binary"; then
        sudo dpkg -i "$protonvpn_deb" 2>>"$ERROR_LOG_FILE" || true
        update_apt_cache
        protonvpn_packages=(
            "proton-vpn-gnome-desktop"
            "libayatana-appindicator3-1"
            "gir1.2-ayatanaappindicator3-0.1"
            "gnome-shell-extension-appindicator"
        )
        install_apt_packages "${protonvpn_packages[@]}"
    fi
fi

# Proton Pass desktop .deb — canonical URLs live in version.json (linked from
# https://www.proton.me/support/set-up-proton-pass-linux). Legacy ProtonPass.deb
# URLs often redirect or no longer serve the package bytes reliably.
proton_pass_deb="$TEMP_DIR/proton-pass.deb"
proton_pass_version_json_urls=(
    "https://www.proton.me/download/PassDesktop/linux/x64/version.json"
    "https://proton.me/download/PassDesktop/linux/x64/version.json"
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
            "$base_url" -o "$json_path" 2>>"$ERROR_LOG_FILE"; then
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
        if "Debian" in ident or ident.startswith(".deb"):
            print(url)
            sys.exit(0)
sys.exit(1)
' "$json_path" 2>>"$ERROR_LOG_FILE") || deb_url=""
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
        "$proton_pass_url" -o "$proton_pass_deb" 2>>"$ERROR_LOG_FILE" && proton_pass_is_valid_deb "$proton_pass_deb"; then
        proton_pass_downloaded=1
        break
    fi
done

if [[ "$proton_pass_downloaded" -eq 1 ]]; then
    sudo dpkg -i "$proton_pass_deb" 2>>"$ERROR_LOG_FILE" || true
    sudo apt-get install -f -y 2>>"$ERROR_LOG_FILE" || true
else
    log_error "Failed to download a valid Proton Pass Debian package"
fi

proton_pass_cli="$TEMP_DIR/proton-pass-cli"
proton_pass_cli_url=$(curl -s https://api.github.com/repos/protonpass/cli/releases/latest 2>>"$ERROR_LOG_FILE" | grep "browser_download_url.*linux-amd64" | cut -d '"' -f 4)
if [[ -n "$proton_pass_cli_url" ]]; then
    download_file_safe "$proton_pass_cli_url" "$proton_pass_cli"
    if [[ -f "$proton_pass_cli" ]] && [[ -s "$proton_pass_cli" ]]; then
        chmod +x "$proton_pass_cli" 2>>"$ERROR_LOG_FILE" || true
        sudo mv "$proton_pass_cli" /usr/local/bin/protonpass 2>>"$ERROR_LOG_FILE" || true
    fi
fi

if [[ ! -f "/usr/share/keyrings/signal-desktop-keyring.gpg" ]]; then
    temp_key_file="$TEMP_DIR/signal-key.asc"
    wget -O "$temp_key_file" https://updates.signal.org/desktop/apt/keys.asc 2>>"$ERROR_LOG_FILE" || true
    if [[ -f "$temp_key_file" ]]; then
        gpg --dearmor < "$temp_key_file" 2>>"$ERROR_LOG_FILE" | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null 2>>"$ERROR_LOG_FILE" || true
    fi
fi

signal_list_file="/etc/apt/sources.list.d/signal-xenial.list"
if [[ ! -f "$signal_list_file" ]] || ! grep -q "updates.signal.org" "$signal_list_file" 2>/dev/null; then
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' 2>>"$ERROR_LOG_FILE" | \
        sudo tee "$signal_list_file" > /dev/null 2>>"$ERROR_LOG_FILE" || true
    update_apt_cache
fi
install_apt_packages "signal-desktop"

apt_security_tools=(
    "nmap"
    "exiftool"
)
install_apt_packages "${apt_security_tools[@]}"

if command -v snap >/dev/null 2>&1; then
    sudo snap install zaproxy --classic 2>>"$ERROR_LOG_FILE" || true
fi

ensure_directory "$HOME/Hacking"

if [[ ! -d "$HOME/Hacking/PayloadsAllTheThings" ]]; then
    clone_repository_safe "https://github.com/swisskyrepo/PayloadsAllTheThings" "$HOME/Hacking/PayloadsAllTheThings"
fi

if [[ ! -d "$HOME/Hacking/SecLists" ]]; then
    clone_repository_safe "https://github.com/danielmiessler/SecLists" "$HOME/Hacking/SecLists"
fi
