#!/bin/bash

expand_home_path() {
    local path="$1"

    if [[ "${path:0:1}" != "~" ]]; then
        printf '%s' "$path"
        return 0
    fi
    if [[ "$path" == "~" ]]; then
        printf '%s' "$HOME"
    elif [[ "${path:1:1}" == "/" ]]; then
        printf '%s/%s' "$HOME" "${path:2}"
    else
        printf '%s' "$path"
    fi
}

copy_dotfile_file() {
    local rel_src="$1"
    local dest
    dest="$(expand_home_path "$2")"
    local src="$PROJECT_ROOT/src/dotfiles/$rel_src"

    [[ -f "$dest" ]] && return 0
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
}

install_dotfiles_from_manifest() {
    local manifest="$1"
    local line kind rel_src dest

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// /}" ]] && continue

        read -r kind rel_src dest <<< "$line"
        if [[ "$kind" == file ]]; then
            copy_dotfile_file "$rel_src" "$dest"
        fi
    done < "$manifest"
}
