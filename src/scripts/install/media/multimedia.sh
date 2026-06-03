#!/bin/bash
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ffmpeg gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-restricted-extras || true
