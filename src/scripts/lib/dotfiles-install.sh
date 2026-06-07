#!/bin/bash

copy_dotfile_dir() {
    local rel_src="$1"
    local dest="$2"
    local src="$PROJECT_ROOT/src/dotfiles/$rel_src"

    [[ -d "$dest" ]] && return 0
    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest"
}

copy_dotfile_file() {
    local rel_src="$1"
    local dest="$2"
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
        case "$kind" in
            dir)
                copy_dotfile_dir "$rel_src" "$dest"
                ;;
            file)
                copy_dotfile_file "$rel_src" "$dest"
                ;;
        esac
    done < "$manifest"
}
