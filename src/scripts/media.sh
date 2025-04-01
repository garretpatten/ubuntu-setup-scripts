#!/bin/bash

# Brave
if [[ ! -f "/usr/bin/brave-browser" ]]; then
    curl -fsS https://dl.brave.com/install.sh | sh
fi

# Spotify
if [[ ! -d "/usr/bin/spotify-launcher" ]]; then
    sudo apt install spotify-launcher -y
fi

# VLC
if [[ ! -f "/usr/bin/vlc" ]]; then
    sudo apt install vlc -y
fi
