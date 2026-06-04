#!/bin/bash
[[ -x /usr/local/bin/ufw-docker ]] && exit 0
sudo wget -q -O /usr/local/bin/ufw-docker \
    https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker || true
sudo chmod +x /usr/local/bin/ufw-docker || true
