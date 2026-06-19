#!/bin/bash

command -v tldr >/dev/null 2>&1 || exit 0

cache_root="${XDG_CACHE_HOME:-$HOME/.cache}/tealdeer"
pages_root="$cache_root/tldr-pages"
archive_url="https://github.com/tldr-pages/tldr/releases/latest/download/tldr-pages.en.zip"

tldr_cache_ready() {
    [[ -d "$pages_root/pages.en" ]] \
        || [[ -d "$pages_root/pages/linux" ]] \
        || [[ -d "$pages_root/pages/common" ]]
}

tldr_english_pages_dir() {
    local version="${1:-$(tldr --version 2>/dev/null | awk '{print $2}')}"
    local major minor

    major="${version%%.*}"
    version="${version#*.}"
    minor="${version%%.*}"

    if [[ "$major" -eq 1 && "$minor" -lt 8 ]]; then
        printf '%s\n' "$pages_root/pages"
    else
        printf '%s\n' "$pages_root/pages.en"
    fi
}

if tldr_cache_ready; then
    exit 0
fi

if tldr -L en --update 2>/dev/null && tldr_cache_ready; then
    exit 0
fi

command -v curl >/dev/null 2>&1 || exit 0
command -v unzip >/dev/null 2>&1 || exit 0

pages_dir="$(tldr_english_pages_dir)"
mkdir -p "$pages_dir"

archive="${TMPDIR:-/tmp}/tldr-pages.en.zip"
if curl -fsSL -o "$archive" "$archive_url"; then
    unzip -oq "$archive" -d "$pages_dir" || true
fi
rm -f "$archive"
