#!/bin/bash

# Shared curl download helpers with aggressive retries against transient
# network/GitHub failures (rate limits and 5xx/504s seen on shared CI runners).
# A failed download is LOUD: these helpers return non-zero and callers are
# expected to propagate the status instead of silently skipping an install.

# download_file URL TARGET -> curl to file with retries.
download_file() {
    local url="$1"
    local target="$2"
    curl -fsSL --retry 5 --retry-delay 2 --retry-max-time 30 --retry-all-errors \
        "$url" -o "$target"
}

# download_installer URL TARGET = download_file plus non-empty validation;
# returns non-zero and cleans up if the download fails or is truncated.
download_installer() {
    local url="$1"
    local target="$2"
    if ! download_file "$url" "$target"; then
        echo "ERROR: download of $url failed" >&2
        rm -f "$target"
        return 1
    fi
    if [[ ! -s "$target" ]]; then
        echo "ERROR: download of $url produced an empty file at $target" >&2
        rm -f "$target"
        return 1
    fi
    return 0
}

# github_latest_release_tag OWNER/REPO -> prints the tag of the latest release
# resolved from the releases/latest redirect; the API is rate-limited on
# shared CI runners, so the redirect is preferred. Non-zero when the redirect
# does not resolve to a tag.
github_latest_release_tag() {
    local tag redirect
    redirect="$(curl -fsSL --retry 3 --retry-delay 2 --retry-all-errors \
        -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest")"
    tag="${redirect##*/tag/}"
    if [[ -z "$tag" || "$tag" == "$redirect" || "$tag" == *"https://"* ]]; then
        echo "ERROR: could not resolve latest release tag for $1" >&2
        return 1
    fi
    printf '%s\n' "$tag"
}
