#!/bin/bash
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git curl software-properties-common apt-transport-https ca-certificates gnupg lsb-release
sudo add-apt-repository -y universe || true
sudo apt-get update -y || true
