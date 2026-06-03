#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
docker_deps=("apt-transport-https" "ca-certificates" "software-properties-common" "gnupg" "lsb-release")
install_apt_packages "${docker_deps[@]}"
if [[ ! -f "/usr/share/keyrings/docker-archive-keyring.gpg" ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg 2>>"$ERROR_LOG_FILE" | \
        sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 2>>"$ERROR_LOG_FILE" || true
fi
if ! grep -q "download.docker.com" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" 2>>"$ERROR_LOG_FILE" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 2>>"$ERROR_LOG_FILE" || true
    update_apt_cache
fi
docker_packages=("docker-ce" "docker-ce-cli" "containerd.io" "docker-compose-plugin")
install_apt_packages "${docker_packages[@]}"
