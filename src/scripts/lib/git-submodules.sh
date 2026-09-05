#!/bin/bash

# Initialize or update Git submodules to the commits pinned in this repository.

ensure_submodules_synced() {
    local project_root="${1:-$PROJECT_ROOT}"
    if [[ -z "${project_root:-}" ]]; then
        echo "ERROR: PROJECT_ROOT is not set; cannot sync submodules." >&2
        return 1
    fi

    if [[ ! -d "$project_root/.git" ]]; then
        echo "WARNING: Not a git repository; skipping submodule sync." >&2
        return 0
    fi

    (
        cd "$project_root" || exit 1
        if git submodule status 2>/dev/null | grep -q '^-'; then
            echo "==> Initializing submodules..."
            git submodule update --init --recursive || true
        else
            echo "==> Updating submodules..."
            git submodule update --recursive || true
        fi
    )
}
