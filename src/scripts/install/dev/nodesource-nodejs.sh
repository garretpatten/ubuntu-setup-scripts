#!/bin/bash
NODE_MAJOR=24
nodesource_key="/etc/apt/keyrings/nodesource.gpg"
nodesource_list="/etc/apt/sources.list.d/nodesource.list"
sudo mkdir -p /etc/apt/keyrings
if [[ ! -f "$nodesource_key" ]]; then
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o "$nodesource_key" || true
fi
if [[ ! -f "$nodesource_list" ]] || ! grep -Fq "deb.nodesource.com/node_${NODE_MAJOR}.x" "$nodesource_list" 2>/dev/null; then
    echo "deb [signed-by=${nodesource_key}] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | sudo tee "$nodesource_list" >/dev/null || true
fi
