#!/usr/bin/env bash
# Install bats-core and helper libraries from release tarballs into .tools/.
# After this runs, `npm run test:shell` works without a system bats install.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
prefix="${repo_root}/.tools"
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

BATS_CORE_VERSION="1.14.0"
BATS_SUPPORT_VERSION="0.3.0"
BATS_ASSERT_VERSION="2.2.4"
BATS_FILE_VERSION="0.4.0"

download_extract() {
    local url="$1"
    local dest="$2"
    local archive="${tmpdir}/archive.tar.gz"
    curl -fsSL "${url}" -o "${archive}"
    rm -rf "${tmpdir}/extract"
    mkdir -p "${tmpdir}/extract"
    tar -xzf "${archive}" -C "${tmpdir}/extract"
    local src
    src="$(find "${tmpdir}/extract" -mindepth 1 -maxdepth 1 -type d | head -1)"
    rm -rf "${dest}"
    mkdir -p "$(dirname "${dest}")"
    mv "${src}" "${dest}"
}

mkdir -p "${prefix}"

download_extract \
    "https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_CORE_VERSION}.tar.gz" \
    "${tmpdir}/bats-core"
"${tmpdir}/bats-core/install.sh" "${prefix}/bats"

download_extract \
    "https://github.com/bats-core/bats-support/archive/refs/tags/v${BATS_SUPPORT_VERSION}.tar.gz" \
    "${prefix}/bats-support"
download_extract \
    "https://github.com/bats-core/bats-assert/archive/refs/tags/v${BATS_ASSERT_VERSION}.tar.gz" \
    "${prefix}/bats-assert"
download_extract \
    "https://github.com/bats-core/bats-file/archive/refs/tags/v${BATS_FILE_VERSION}.tar.gz" \
    "${prefix}/bats-file"

echo "Installed bats-core ${BATS_CORE_VERSION} plus helper libraries to ${prefix}"
echo "Run tests with: npm run test:shell"
