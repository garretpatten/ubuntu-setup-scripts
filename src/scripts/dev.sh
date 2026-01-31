#!/bin/bash

# Development Tools Installation Script
# Installs programming languages, frameworks, and development tools
# Author: Garret Patten

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

# Install Node.js
local node_setup_script="$TEMP_DIR/nodejs_setup.sh"
download_file_safe "https://deb.nodesource.com/setup_lts.x" "$node_setup_script"
sudo bash "$node_setup_script" 2>>"$ERROR_LOG_FILE" || true
update_apt_cache
install_apt_packages "nodejs"

# Install NVM
if [[ ! -d "$HOME/.nvm" ]]; then
    local nvm_install_script="$TEMP_DIR/nvm_install.sh"
    download_file_safe "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh" "$nvm_install_script"
    bash "$nvm_install_script" 2>>"$ERROR_LOG_FILE" || true
fi

# Install Python
local python_packages=(
    "python3"
    "python3-pip"
    "python3-venv"
    "python3-dev"
)
install_apt_packages "${python_packages[@]}"

# Install Vue.js CLI
sudo npm install -g @vue/cli 2>>"$ERROR_LOG_FILE" || true

# Install Docker
local docker_deps=(
    "apt-transport-https"
    "ca-certificates"
    "software-properties-common"
    "gnupg"
    "lsb-release"
)
install_apt_packages "${docker_deps[@]}"

# Add Docker GPG key and repository
if [[ ! -f "/usr/share/keyrings/docker-archive-keyring.gpg" ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 2>>"$ERROR_LOG_FILE" || true
fi

if ! grep -q "download.docker.com" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    update_apt_cache
fi

local docker_packages=(
    "docker-ce"
    "docker-ce-cli"
    "containerd.io"
    "docker-compose-plugin"
)
install_apt_packages "${docker_packages[@]}"

# Pull common Docker images
docker image pull ubuntu:latest 2>>"$ERROR_LOG_FILE" || true
docker image pull alpine:latest 2>>"$ERROR_LOG_FILE" || true

# Install Neovim
sudo add-apt-repository -y ppa:neovim-ppa/stable 2>>"$ERROR_LOG_FILE" || true
update_apt_cache

local neovim_packages=(
    "neovim"
    "python3-neovim"
    "python3-dev"
    "python3-pip"
)
install_apt_packages "${neovim_packages[@]}"

# Install pynvim and LSP servers
pip3 install --user pynvim 2>>"$ERROR_LOG_FILE" || true
npm install -g typescript-language-server pyright vscode-langservers-extracted vsnip 2>>"$ERROR_LOG_FILE" || true

# Install Neovim Packer
local packer_dir="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
if [[ ! -d "$packer_dir" ]]; then
    clone_repository_safe "https://github.com/wbthomason/packer.nvim" "$packer_dir" "1"
fi

# Install development tools
local dev_tools=(
    "gh"
    "shellcheck"
    "git"
)
install_apt_packages "${dev_tools[@]}"

# Install Postman via Flatpak
flatpak install -y flathub com.getpostman.Postman 2>>"$ERROR_LOG_FILE" || true

# Install Cursor IDE
local cursor_appimage="$TEMP_DIR/cursor.AppImage"
download_file_safe "https://downloader.cursor.sh/linux/appImage/x64" "$cursor_appimage"
if [[ -f "$cursor_appimage" ]]; then
    chmod +x "$cursor_appimage"
    sudo ln -sf "$cursor_appimage" /usr/local/bin/cursor 2>>"$ERROR_LOG_FILE" || true

    ensure_directory "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/cursor.desktop" << 'EOF'
[Desktop Entry]
Name=Cursor
Comment=The AI-first code editor
Exec=/usr/local/bin/cursor %U
Icon=cursor
Terminal=false
Type=Application
Categories=Development;TextEditor;
MimeType=text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/javascript;application/json;text/css;text/x-sql;text/xml;
StartupWMClass=Cursor
EOF
fi

# Configure Git
if [[ ! -f "$HOME/.gitconfig" ]]; then
    git config --global credential.helper store
    git config --global http.postBuffer 157286400
    git config --global pack.window 1
    git config --global user.email "garret.patten@proton.me"
    git config --global user.name "Garret Patten"
    git config --global pull.rebase false
    git config --global init.defaultBranch main
fi

# Configure Neovim
local nvim_config_dir="$HOME/.config/nvim"
local nvim_source_dir="$PROJECT_ROOT/src/dotfiles/nvim"

if [[ ! -d "$nvim_config_dir" ]]; then
    ensure_directory "$nvim_config_dir"
    if [[ -d "$nvim_source_dir" ]]; then
        cp -r "$nvim_source_dir/"* "$nvim_config_dir/" 2>>"$ERROR_LOG_FILE" || true
    else
        cat > "$nvim_config_dir/init.lua" << 'EOF'
-- Basic Neovim configuration
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

-- Key mappings
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>e", ":Ex<CR>", { desc = "Open file explorer" })
EOF
    fi
fi

# Configure Vim
local vim_config_file="$HOME/.vimrc"
local vim_source_file="$PROJECT_ROOT/src/dotfiles/vim/.vimrc"
if [[ ! -f "$vim_config_file" && -f "$vim_source_file" ]]; then
copy_file_safe "$vim_source_file" "$vim_config_file"
fi
