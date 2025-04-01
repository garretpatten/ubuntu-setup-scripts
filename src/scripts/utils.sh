#!/bin/bash

is_installed() {
    local application="$1"
    # shellcheck disable=SC1014,SC2057
    [[ command -v "$application" ]] && return 0 || return 1
}

export ERROR_FILE="errors.log"
