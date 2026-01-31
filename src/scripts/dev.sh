#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

local node_setup_script="$TEMP_DIR/nodejs_setup.sh"
download_file_safe "https://deb.nodesource.com/setup_lts.x" "$node_setup_script"
sudo bash "$node_setup_script" 2>>"$ERROR_LOG_FILE" || true
update_apt_cache
install_apt_packages "nodejs"

if [[ ! -d "$HOME/.nvm" ]]; then
    local nvm_install_script="$TEMP_DIR/nvm_install.sh"
    download_file_safe "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh" "$nvm_install_script"
    bash "$nvm_install_script" 2>>"$ERROR_LOG_FILE" || true
fi

local python_packages=(
    "python3"
    "python3-pip"
    "python3-venv"
    "python3-dev"
)
install_apt_packages "${python_packages[@]}"

sudo npm install -g @vue/cli 2>>"$ERROR_LOG_FILE" || true

local docker_deps=(
    "apt-transport-https"
    "ca-certificates"
    "software-properties-common"
    "gnupg"
    "lsb-release"
)
install_apt_packages "${docker_deps[@]}"

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

sudo add-apt-repository -y ppa:neovim-ppa/stable 2>>"$ERROR_LOG_FILE" || true
update_apt_cache

local neovim_packages=(
    "neovim"
    "python3-neovim"
    "python3-dev"
    "python3-pip"
)
install_apt_packages "${neovim_packages[@]}"

local packer_dir="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
if [[ ! -d "$packer_dir" ]]; then
    clone_repository_safe "https://github.com/wbthomason/packer.nvim" "$packer_dir" "1"
fi

local dev_tools=(
    "gh"
    "shellcheck"
    "git"
)
install_apt_packages "${dev_tools[@]}"

flatpak install -y flathub com.getpostman.Postman 2>>"$ERROR_LOG_FILE" || true

pip3 install --user semgrep 2>>"$ERROR_LOG_FILE" || true

local sg_binary="$TEMP_DIR/sg"
download_file_safe "https://sourcegraph.com/.api/src-cli/src_linux_amd64" "$sg_binary"
if [[ -f "$sg_binary" ]]; then
    chmod +x "$sg_binary"
    sudo mv "$sg_binary" /usr/local/bin/sg 2>>"$ERROR_LOG_FILE" || true
fi

if [[ ! -f "$HOME/.gitconfig" ]]; then
    git config --global credential.helper store
    git config --global http.postBuffer 157286400
    git config --global pack.window 1
    git config --global user.email "garret.patten@proton.me"
    git config --global user.name "Garret Patten"
    git config --global pull.rebase false
    git config --global init.defaultBranch main
fi

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

local vim_config_file="$HOME/.vimrc"
local vim_source_file="$PROJECT_ROOT/src/dotfiles/vim/.vimrc"
if [[ ! -f "$vim_config_file" && -f "$vim_source_file" ]]; then
copy_file_safe "$vim_source_file" "$vim_config_file"
fi
