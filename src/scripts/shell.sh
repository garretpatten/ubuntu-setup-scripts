#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

local shell_packages=(
    "zsh"
    "tmux"
    "powerline"
)
install_apt_packages "${shell_packages[@]}"

local ghostty_deb="$TEMP_DIR/ghostty.deb"
download_file_safe "https://github.com/ghostty-org/ghostty/releases/latest/download/ghostty-linux-x86_64.deb" "$ghostty_deb"
if [[ -f "$ghostty_deb" ]]; then
    sudo dpkg -i "$ghostty_deb" 2>>"$ERROR_LOG_FILE" || true
    sudo apt-get install -f -y 2>>"$ERROR_LOG_FILE" || true
fi

local font_packages=(
    "fonts-font-awesome"
    "fonts-firacode"
    "fonts-powerline"
)
install_apt_packages "${font_packages[@]}"

local font_dir="/usr/share/fonts/meslo-nerd-font"
if [[ ! -d "$font_dir" ]]; then
    local temp_font_dir="$TEMP_DIR/meslo-font"
    ensure_directory "$temp_font_dir"
    local meslo_zip="$temp_font_dir/Meslo.zip"
    download_file_safe "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip" "$meslo_zip"
    if [[ -f "$meslo_zip" ]]; then
        sudo mkdir -p "$font_dir"
        unzip -q "$meslo_zip" -d "$temp_font_dir" 2>>"$ERROR_LOG_FILE" || true
        sudo mv "$temp_font_dir"/*.ttf "$font_dir/" 2>/dev/null || true
        sudo mv "$temp_font_dir"/*.otf "$font_dir/" 2>/dev/null || true
        sudo chmod 644 "$font_dir"/*.ttf 2>/dev/null || true
        sudo chmod 644 "$font_dir"/*.otf 2>/dev/null || true
    fi
fi

fc-cache -fv 2>>"$ERROR_LOG_FILE" || true

local plugin_packages=(
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
)
install_apt_packages "${plugin_packages[@]}"

local omp_install_script="$TEMP_DIR/oh-my-posh-install.sh"
download_file_safe "https://ohmyposh.dev/install.sh" "$omp_install_script"
if [[ -f "$omp_install_script" ]]; then
    bash "$omp_install_script" -s -- --user 2>>"$ERROR_LOG_FILE" || true
fi

local themes_dir="/usr/share/oh-my-posh/themes"
if [[ ! -d "$themes_dir" ]] || [[ -z "$(ls -A "$themes_dir" 2>/dev/null)" ]]; then
    sudo mkdir -p "$themes_dir"
    local temp_repo_dir="$TEMP_DIR/oh-my-posh-repo"
    clone_repository_safe "https://github.com/JanDeDobbeleer/oh-my-posh.git" "$temp_repo_dir"
    if [[ -d "$temp_repo_dir/themes" ]]; then
        sudo cp -r "$temp_repo_dir/themes/"* "$themes_dir/" 2>>"$ERROR_LOG_FILE" || true
        sudo chmod -R 755 "$themes_dir" 2>>"$ERROR_LOG_FILE" || true
        sudo chown -R root:root "$themes_dir" 2>>"$ERROR_LOG_FILE" || true
    fi
fi

local ghostty_config_dir="$HOME/.config/ghostty"
local ghostty_source_file="$PROJECT_ROOT/src/dotfiles/ghostty/config"

if [[ ! -d "$ghostty_config_dir" ]]; then
    ensure_directory "$ghostty_config_dir"
    if [[ -f "$ghostty_source_file" ]]; then
        copy_file_safe "$ghostty_source_file" "$ghostty_config_dir/config"
    fi
fi

local tmux_config_file="$HOME/.tmux.conf"
local tmux_source_file="$PROJECT_ROOT/src/dotfiles/tmux/.tmux.conf"

if [[ ! -f "$tmux_config_file" ]]; then
    if [[ -f "$tmux_source_file" ]]; then
        copy_file_safe "$tmux_source_file" "$tmux_config_file"
    else
        cat > "$tmux_config_file" << 'EOF'
# Tmux Configuration
# Set prefix to Ctrl-a
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Enable mouse mode
set -g mouse on

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Reload config file
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
EOF
    fi
fi

local zsh_config_file="$HOME/.zshrc"
local zsh_source_file="$PROJECT_ROOT/src/dotfiles/oh-my-posh/.zshrc"

if [[ ! -f "$zsh_config_file" ]]; then
    if [[ -f "$zsh_source_file" ]]; then
        copy_file_safe "$zsh_source_file" "$zsh_config_file"
    else
        cat > "$zsh_config_file" << 'EOF'
# Z Shell Configuration

# Enable Oh My Posh if installed
if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init zsh)"
fi

# Enable zsh plugins if available
if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS

# Enable completion
autoload -Uz compinit
compinit

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# Set default editor
export EDITOR=vim
EOF
    fi
fi

local zsh_path
zsh_path="$(which zsh 2>/dev/null || echo "")"
if [[ -n "$zsh_path" && "$SHELL" != "$zsh_path" ]]; then
    chsh -s "$zsh_path" 2>>"$ERROR_LOG_FILE" || true
fi
