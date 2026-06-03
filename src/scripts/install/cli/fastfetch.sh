#!/bin/bash
sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch || true
sudo apt-get update -y || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y fastfetch
