#!/bin/bash

sudo apt-get update -y || true
sudo NEEDRESTART_MODE=l apt-get upgrade -y || true
sudo apt-get autoremove -y || true
sudo apt-get autoclean || true
