#!/bin/bash

apt_maintain_update() {
    sudo apt-get update -y || true
}

apt_maintain_cleanup() {
    sudo apt-get autoremove -y || true
    sudo apt-get autoclean || true
}
