#!/bin/bash

apt_maintain_update() {
    sudo apt-get update -y || true
}

apt_maintain_full() {
    sudo apt-get update -y || true
    sudo NEEDRESTART_MODE=l apt-get upgrade -y || true
    sudo apt-get autoremove -y || true
    sudo apt-get autoclean || true
}
