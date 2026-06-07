#!/bin/bash

FAILURES=0

section() {
    printf '\n== %s ==\n' "$1"
}

pass() {
    local name="$1"
    local detail="${2:-}"
    if [[ -n "$detail" ]]; then
        printf '  ok  %-28s %s\n' "$name" "$detail"
    else
        printf '  ok  %s\n' "$name"
    fi
}

fail() {
    local name="$1"
    local detail="${2:-not found}"
    printf '  FAIL %-28s %s\n' "$name" "$detail" >&2
    FAILURES=$((FAILURES + 1))
}

version_of() {
    local cmd=("$@")
    "${cmd[@]}" 2>/dev/null | head -n1 | tr -d '\r' || true
}

check_version() {
    local name="$1"
    shift
    local rc=0
    "$@" >/dev/null 2>&1 || rc=$?
    if [[ "$rc" -eq 0 ]]; then
        pass "$name" "$(version_of "$@")"
    else
        fail "$name" "expected: $*"
    fi
}

check_command() {
    local name="$1"
    local bin="$2"
    if command -v "$bin" >/dev/null 2>&1; then
        pass "$name" "$(command -v "$bin")"
    else
        fail "$name" "command not in PATH: $bin"
    fi
}

check_dpkg() {
    local name="$1"
    local pkg="$2"
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        pass "$name" "$(dpkg -s "$pkg" 2>/dev/null | awk -F': ' '/^Version:/{print $2; exit}')"
    else
        fail "$name" "dpkg package missing: $pkg"
    fi
}

check_path() {
    local name="$1"
    local path="$2"
    if [[ -e "$path" ]]; then
        pass "$name" "$path"
    else
        fail "$name" "missing path: $path"
    fi
}

snap_installed() {
    local snap_name="$1"
    snap list "$snap_name" 2>/dev/null | grep -q "^${snap_name} "
}

finish_validation() {
    local label="$1"
    printf '\n'
    if [[ "$FAILURES" -gt 0 ]]; then
        printf '%s failed: %d check(s).\n' "$label" "$FAILURES" >&2
        exit 1
    fi
    printf '%s passed.\n' "$label"
}
