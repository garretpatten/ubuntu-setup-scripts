#!/bin/bash

credential_src="/usr/share/doc/git/contrib/credential/libsecret"
credential_bin="$credential_src/git-credential-libsecret"

if [[ ! -d "$credential_src" ]]; then
    exit 0
fi

if [[ -x "$credential_bin" ]]; then
    exit 0
fi

if ! dpkg -s libsecret-1-dev >/dev/null 2>&1; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends libsecret-1-dev || exit 0
fi

cd "$credential_src" || exit 0
sudo make || true
