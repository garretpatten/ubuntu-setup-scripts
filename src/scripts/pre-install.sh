#!/bin/bash

# Initial system update
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get autoremove -y

# Git
if [[ ! -f "/usr/bin/git" ]]; then
    sudo apt-get install git -y
fi
