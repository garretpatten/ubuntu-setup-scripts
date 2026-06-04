#!/usr/bin/env bash
# Replicate CI ShellCheck: changed .sh/.bash/.zsh vs base branch, with -x and .shellcheckrc.
set -euo pipefail

cd "$(dirname "$0")/.."

git fetch origin main master 2>/dev/null || true
if git show-ref --verify --quiet refs/remotes/origin/master; then
    BASE_REF="origin/master"
elif git show-ref --verify --quiet refs/remotes/origin/main; then
    BASE_REF="origin/main"
else
    BASE_REF="HEAD~1"
fi

mapfile -t CHANGED < <(git diff --name-only --diff-filter=ACMR "${BASE_REF}"...HEAD | grep -E '\.(sh|bash|zsh)$' || true)

paths=()
for file in "${CHANGED[@]}"; do
    [[ -n "$file" && -f "$file" ]] && paths+=("$file")
done

if [[ ${#paths[@]} -eq 0 ]]; then
    echo "No changed shell files to check (base: ${BASE_REF})"
    exit 0
fi

echo "ShellCheck -x (${#paths[@]} files, base: ${BASE_REF})"
shellcheck -x "${paths[@]}"
