#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

shell_packages=(
    "zsh"
    "tmux"
    "powerline"
)
install_apt_packages "${shell_packages[@]}"

ghostty_deb="$TEMP_DIR/ghostty.deb"
ghostty_latest_url=$(curl -s https://api.github.com/repos/ghostty-org/ghostty/releases/latest 2>>"$ERROR_LOG_FILE" | grep "browser_download_url.*linux-x86_64.deb" | cut -d '"' -f 4)
if [[ -n "$ghostty_latest_url" ]]; then
    download_file_safe "$ghostty_latest_url" "$ghostty_deb"
fi
if [[ -f "$ghostty_deb" ]]; then
    sudo dpkg -i "$ghostty_deb" 2>>"$ERROR_LOG_FILE" || true
    sudo apt-get install -f -y 2>>"$ERROR_LOG_FILE" || true
fi

font_packages=(
    "fonts-font-awesome"
    "fonts-firacode"
    "fonts-powerline"
)
install_apt_packages "${font_packages[@]}"

font_dir="/usr/share/fonts/meslo-nerd-font"
if [[ ! -d "$font_dir" ]]; then
    temp_font_dir="$TEMP_DIR/meslo-font"
    ensure_directory "$temp_font_dir"
    meslo_zip="$temp_font_dir/Meslo.zip"
    download_file_safe "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip" "$meslo_zip"
    if [[ -f "$meslo_zip" ]]; then
        sudo mkdir -p "$font_dir" 2>>"$ERROR_LOG_FILE" || true
        unzip -q "$meslo_zip" -d "$temp_font_dir" 2>>"$ERROR_LOG_FILE" || true
        sudo mv "$temp_font_dir"/*.ttf "$font_dir/" 2>>"$ERROR_LOG_FILE" || true
        if ls "$temp_font_dir"/*.otf 1>/dev/null 2>&1; then
            sudo mv "$temp_font_dir"/*.otf "$font_dir/" 2>>"$ERROR_LOG_FILE" || true
        fi
        if ls "$font_dir"/*.ttf 1>/dev/null 2>&1; then
            sudo chmod 644 "$font_dir"/*.ttf 2>>"$ERROR_LOG_FILE" || true
        fi
        if ls "$font_dir"/*.otf 1>/dev/null 2>&1; then
            sudo chmod 644 "$font_dir"/*.otf 2>>"$ERROR_LOG_FILE" || true
        fi
    fi
fi

fc-cache -fv 2>>"$ERROR_LOG_FILE" || true

plugin_packages=(
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
)
install_apt_packages "${plugin_packages[@]}"

omp_install_script="$TEMP_DIR/oh-my-posh-install.sh"
download_file_safe "https://ohmyposh.dev/install.sh" "$omp_install_script"
if [[ -f "$omp_install_script" ]]; then
    bash "$omp_install_script" -s -- --user 2>>"$ERROR_LOG_FILE" || true
fi

themes_dir="/usr/share/oh-my-posh/themes"
if [[ ! -d "$themes_dir" ]] || [[ -z "$(ls -A "$themes_dir" 2>/dev/null)" ]]; then
    sudo mkdir -p "$themes_dir" 2>>"$ERROR_LOG_FILE" || true
    temp_repo_dir="$TEMP_DIR/oh-my-posh-repo"
    clone_repository_safe "https://github.com/JanDeDobbeleer/oh-my-posh.git" "$temp_repo_dir"
    if [[ -d "$temp_repo_dir/themes" ]]; then
        sudo cp -r "$temp_repo_dir/themes/"* "$themes_dir/" 2>>"$ERROR_LOG_FILE" || true
        sudo chmod -R 755 "$themes_dir" 2>>"$ERROR_LOG_FILE" || true
        sudo chown -R root:root "$themes_dir" 2>>"$ERROR_LOG_FILE" || true
    fi
fi

ghostty_config_dir="$HOME/.config/ghostty"
ghostty_source_file="$PROJECT_ROOT/src/dotfiles/ghostty/config"

if [[ ! -d "$ghostty_config_dir" ]]; then
    ensure_directory "$ghostty_config_dir"
    if [[ -f "$ghostty_source_file" ]]; then
        copy_file_safe "$ghostty_source_file" "$ghostty_config_dir/config"
    fi
fi

tmux_config_file="$HOME/.tmux.conf"
tmux_source_file="$PROJECT_ROOT/src/dotfiles/tmux/.tmux.conf"

if [[ ! -f "$tmux_config_file" && -f "$tmux_source_file" ]]; then
    copy_file_safe "$tmux_source_file" "$tmux_config_file"
fi

zsh_config_file="$HOME/.zshrc"
zsh_source_file="$PROJECT_ROOT/src/dotfiles/oh-my-posh/.zshrc"

if [[ ! -f "$zsh_config_file" && -f "$zsh_source_file" ]]; then
    copy_file_safe "$zsh_source_file" "$zsh_config_file"
fi

# zsh_path
zsh_path="$(which zsh 2>/dev/null || echo "")"
if [[ -n "$zsh_path" && "$SHELL" != "$zsh_path" ]]; then
    chsh -s "$zsh_path" 2>/dev/null || true
fi
