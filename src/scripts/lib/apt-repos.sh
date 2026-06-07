#!/bin/bash

# Batch PPA additions; parallelize when more than two are required.

add_ppas_parallel() {
    local -a ppas=("$@")

    if [[ ${#ppas[@]} -eq 0 ]]; then
        return 0
    fi

    if [[ ${#ppas[@]} -gt 2 ]]; then
        printf '%s\n' "${ppas[@]}" | xargs -P 2 -I{} sudo add-apt-repository -y {} || true
    else
        local ppa
        for ppa in "${ppas[@]}"; do
            sudo add-apt-repository -y "$ppa" || true
        done
    fi
}
