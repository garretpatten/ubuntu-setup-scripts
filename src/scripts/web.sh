#!/bin/bash

packageManager=$1

# Brave
if [[ -f "/usr/bin/brave-browser" ]]; then
    echo "Braver browser is already installed."
else
    if [[ "$packageManager" = "dnf" ]]; then
        sudo dnf install dnf-plugins-core -y
        sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
        sudo dnf install brave-browser -y
    elif [[ "$packageManager" = "pacman" ]]; then
        yay -S --noconfirm brave-bin
    else
        # TODO: Add support for apt
        echo "Support not yet added for apt."
    fi
fi
