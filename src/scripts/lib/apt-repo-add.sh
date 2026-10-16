#!/bin/bash

add_repo_keyring_from_curl() {
    local key_url="$1"
    local keyring_path="$2"

    if [[ ! -f "$keyring_path" ]]; then
        curl -fsSL "$key_url" | sudo gpg --dearmor -o "$keyring_path" || true
    fi
}

add_repo_keyring_from_wget() {
    local key_url="$1"
    local keyring_path="$2"
    local key_file

    key_file="$TEMP_DIR/repo-key-$(basename "$keyring_path").asc"

    if [[ ! -f "$keyring_path" ]]; then
        wget -qO "$key_file" "$key_url" || true
        if [[ -f "$key_file" ]]; then
            gpg --dearmor < "$key_file" | sudo tee "$keyring_path" >/dev/null || true
        fi
    fi
}

add_repo_list_if_missing() {
    local list_path="$1"
    local grep_pattern="$2"
    local deb_line="$3"

    if [[ ! -f "$list_path" ]] || ! grep -q "$grep_pattern" "$list_path" 2>/dev/null; then
        echo "$deb_line" | sudo tee "$list_path" >/dev/null || true
    fi
}

expand_repo_deb_line() {
    local deb_line="$1"
    deb_line="${deb_line//ARCH/$(dpkg --print-architecture)}"
    deb_line="${deb_line//CODENAME/$(lsb_release -cs)}"
    printf '%s' "$deb_line"
}

setup_bruno_repo() {
    if command -v bruno >/dev/null 2>&1; then
        return 0
    fi

    local bruno_keyring="/etc/apt/keyrings/bruno.gpg"
    if [[ ! -f "$bruno_keyring" ]]; then
        curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x9FA6017ECABE0266" | \
            sudo gpg --dearmor -o "$bruno_keyring" || true
        sudo chmod 644 "$bruno_keyring" 2>/dev/null || true
    fi

    add_repo_list_if_missing \
        "/etc/apt/sources.list.d/bruno.list" \
        debian.usebruno.com \
        "deb [arch=amd64 signed-by=$bruno_keyring] http://debian.usebruno.com/ bruno stable"
}

setup_nodesource_repo() {
    local nodesource_key="/etc/apt/keyrings/nodesource.gpg"
    local nodesource_list="/etc/apt/sources.list.d/nodesource.list"

    sudo mkdir -p /etc/apt/keyrings
    add_repo_keyring_from_curl \
        "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" \
        "$nodesource_key"
    add_repo_list_if_missing \
        "$nodesource_list" \
        "deb.nodesource.com/node_24.x" \
        "deb [signed-by=${nodesource_key}] https://deb.nodesource.com/node_24.x nodistro main"
}

setup_repo_from_manifest_line() {
    local kind="$1"
    shift

    case "$kind" in
        repo)
            local key_url="$1"
            local keyring_path="$2"
            local list_path="$3"
            local grep_pattern="$4"
            local deb_line
            deb_line="$(expand_repo_deb_line "$5")"
            add_repo_keyring_from_curl "$key_url" "$keyring_path"
            add_repo_list_if_missing "$list_path" "$grep_pattern" "$deb_line"
            ;;
        wget)
            local key_url="$1"
            local keyring_path="$2"
            local list_path="$3"
            local grep_pattern="$4"
            local deb_line="$5"
            add_repo_keyring_from_wget "$key_url" "$keyring_path"
            add_repo_list_if_missing "$list_path" "$grep_pattern" "$deb_line"
            ;;
        bruno)
            setup_bruno_repo
            ;;
        nodesource)
            setup_nodesource_repo
            ;;
    esac
}
