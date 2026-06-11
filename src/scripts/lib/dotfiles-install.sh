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

# Symlink src/dotfiles/config/<app>/ → ~/.config/<app>/ (replaces dotfiles setup.sh --link-xdg-config).
link_dotfiles_xdg_config_dirs() {
    local root="$PROJECT_ROOT/src/dotfiles"
    local config_dir="$root/config"
    [[ -d "$config_dir" ]] || return 0

    shopt -s nullglob
    local xdg="${XDG_CONFIG_HOME:-$HOME/.config}"
    mkdir -p "$xdg"

    local dir name src_abs target bak failed=0
    for dir in "$config_dir/"*/; do
        [[ -d "$dir" ]] || continue
        name="$(basename "${dir%/}")"
        src_abs="$(cd "${dir%/}" && pwd)"
        target="${xdg}/${name}"

        if [[ -e "$target" || -L "$target" ]] && [[ ! -L "$target" ]]; then
            bak="${target}.dotfiles-bak-$(date +%Y%m%d%H%M%S)"
            printf '%s exists; moving to %s\n' "$target" "$bak" >&2
            mv "$target" "$bak" || failed=1
        fi

        if [[ "$(readlink "$target" 2>/dev/null)" == "$src_abs" ]]; then
            continue
        fi

        ln -sfn "$src_abs" "$target"
    done
    shopt -u nullglob
    [[ "$failed" -eq 0 ]]
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
