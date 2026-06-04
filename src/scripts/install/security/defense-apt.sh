#!/bin/bash
sudo apt-get update -y || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ufw openvpn
