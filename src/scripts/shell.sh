#!/bin/bash

source "$(pwd)/src/scripts/utils.sh"

### Shells ###

# Alacritty
if ! is_installed "alacritty"; then
    sudo apt-get install alacritty -y
fi

# Z Shell
if ! is_installed "zsh"; then
    sudo apt-get install zsh -y
fi

### Fonts ###

# Awesome Terminal Fonts
if [[ ! -d "/usr/share/fonts/awesome-terminal-fonts/" ]]; then
    sudo apt-get install fonts-font-awesome -y
fi

# Fira Code Fonts
if [[ ! -d "/usr/share/fonts/FiraCode/" ]]; then
    sudo apt-get install fonts-firacode -y
fi

if [[ ! -d "/usr/share/fonts/TTF/" ]]; then
    sudo apt-get install fonts-freefont-ttf -y
fi

# Powerline Fonts
if [[ ! -d "/usr/share/fonts/OTF/" ]]; then
    sudo apt-get install fonts-powerline -y
fi

### Plugins ###

### Oh-my-posh ###
if [[ ! -f "/usr/bin/oh-my-posh" ]]; then
    curl -s https://ohmyposh.dev/install.sh | bash -s
fi

# Tmux
if ! is_installed "tmux"; then
    sudo apt-get install tmux -y
fi

# Zsh Autosuggestions
if [[ ! -d "/usr/share/zsh/plugins/zsh-autosuggestions/" ]]; then
    sudo apt-get install zsh-autosuggestions -y
fi

# Zsh Syntax Highlighting
if [[ ! -d "/usr/share/zsh/plugins/zsh-syntax-highlighting/" ]]; then
    sudo apt-get install zsh-syntax-highlighting -y
fi

### Terminal Configuration ###

# Alacritty
if [[ ! -d "$HOME/.config/alacritty/" ]]; then
    mkdir -p "$HOME/.config/alacritty"
    git clone https://github.com/alacritty/alacritty-theme "$HOME/.config/alacritty/" || {
        echo "Failed to clone https://github.com/alacritty/alacritty-theme." >> "$ERROR_FILE";
    }
    touch "$HOME/.config/alacritty/alacritty.toml"
    cp "$workingDirectory/src/dotfiles/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml" || {
        echo "Failed to configure alacritty." >> "$ERROR_FILE";
    }
fi

# System
chsh -s "$(which zsh)"
sudo chsh -s "$(which zsh)"

# Tmux
if [[ ! -f "$HOME/.tmux.conf" ]]; then
    touch "$HOME/.tmux.conf"
    cp "$(pwd)/src/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf" || {
        echo "Failed to configure tmux." >> "$ERROR_FILE";
    }
fi

# Z Shell
if [[ ! -f "$HOME/.zshrc" ]]; then
    touch "$HOME/.zshrc"
    cp "$(pwd)/src/dotfiles/oh-my-posh/.zshrc" "$HOME/.zshrc" || {
        echo "Failed to configure zsh." >> "$ERROR_FILE";
    }
fi
