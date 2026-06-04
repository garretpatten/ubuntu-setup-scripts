#!/bin/bash
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates software-properties-common gnupg lsb-release
if [[ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg || true
fi
if ! grep -q download.docker.com /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |         sudo tee /etc/apt/sources.list.d/docker.list >/dev/null || true
    sudo apt-get update -y || true
fi
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
