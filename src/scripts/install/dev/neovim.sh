#!/bin/bash
sudo add-apt-repository -y ppa:neovim-ppa/stable || true
sudo apt-get update -y || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y neovim python3-neovim python3-dev python3-pip
