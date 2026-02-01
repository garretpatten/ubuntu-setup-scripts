#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

update_apt_cache

node_setup_script="$TEMP_DIR/nodejs_setup.sh"
download_file_safe "https://deb.nodesource.com/setup_lts.x" "$node_setup_script"
sudo bash "$node_setup_script" 2>>"$ERROR_LOG_FILE" || true
update_apt_cache
install_apt_packages "nodejs"

if [[ ! -d "$HOME/.nvm" ]]; then
    nvm_install_script="$TEMP_DIR/nvm_install.sh"
    download_file_safe "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh" "$nvm_install_script"
    bash "$nvm_install_script" 2>>"$ERROR_LOG_FILE" || true
fi

python_packages=(
    "python3"
    "python3-pip"
    "python3-venv"
    "python3-dev"
)
install_apt_packages "${python_packages[@]}"

sudo npm install -g @vue/cli --loglevel=error 2>>"$ERROR_LOG_FILE" || true

docker_deps=(
    "apt-transport-https"
    "ca-certificates"
    "software-properties-common"
    "gnupg"
    "lsb-release"
)
install_apt_packages "${docker_deps[@]}"

if [[ ! -f "/usr/share/keyrings/docker-archive-keyring.gpg" ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg 2>>"$ERROR_LOG_FILE" | \
        sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 2>>"$ERROR_LOG_FILE" || true
fi

if ! grep -q "download.docker.com" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" 2>>"$ERROR_LOG_FILE" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 2>>"$ERROR_LOG_FILE" || true
    update_apt_cache
fi

docker_packages=(
    "docker-ce"
    "docker-ce-cli"
    "containerd.io"
    "docker-compose-plugin"
)
install_apt_packages "${docker_packages[@]}"

sudo add-apt-repository -y ppa:neovim-ppa/stable 2>>"$ERROR_LOG_FILE" || true
update_apt_cache

neovim_packages=(
    "neovim"
    "python3-neovim"
    "python3-dev"
    "python3-pip"
)
install_apt_packages "${neovim_packages[@]}"

packer_dir="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
if [[ ! -d "$packer_dir" ]]; then
    clone_repository_safe "https://github.com/wbthomason/packer.nvim" "$packer_dir" "1"
fi

dev_tools=(
    "gh"
    "shellcheck"
    "git"
)
install_apt_packages "${dev_tools[@]}"

if flatpak remote-info flathub >/dev/null 2>&1; then
    flatpak install -y flathub com.getpostman.Postman 2>>"$ERROR_LOG_FILE" || true
fi

pip3 install --user semgrep 2>>"$ERROR_LOG_FILE" || true

sg_binary="$TEMP_DIR/sg"
download_file_safe "https://sourcegraph.com/.api/src-cli/src_linux_amd64" "$sg_binary"
if [[ -f "$sg_binary" ]]; then
    chmod +x "$sg_binary" 2>>"$ERROR_LOG_FILE" || true
    sudo mv "$sg_binary" /usr/local/bin/sg 2>>"$ERROR_LOG_FILE" || true
fi

if [[ ! -f "$HOME/.gitconfig" ]]; then
    git config --global credential.helper store 2>>"$ERROR_LOG_FILE" || true
    git config --global http.postBuffer 157286400 2>>"$ERROR_LOG_FILE" || true
    git config --global pack.window 1 2>>"$ERROR_LOG_FILE" || true
    git config --global user.email "garret.patten@proton.me" 2>>"$ERROR_LOG_FILE" || true
    git config --global user.name "Garret Patten" 2>>"$ERROR_LOG_FILE" || true
    git config --global pull.rebase false 2>>"$ERROR_LOG_FILE" || true
    git config --global init.defaultBranch main 2>>"$ERROR_LOG_FILE" || true
fi

nvim_config_dir="$HOME/.config/nvim"
nvim_source_dir="$PROJECT_ROOT/src/dotfiles/nvim"

if [[ ! -d "$nvim_config_dir" && -d "$nvim_source_dir" ]]; then
    ensure_directory "$nvim_config_dir"
    cp -r "$nvim_source_dir/"* "$nvim_config_dir/" 2>>"$ERROR_LOG_FILE" || true
fi

vim_config_file="$HOME/.vimrc"
vim_source_file="$PROJECT_ROOT/src/dotfiles/vim/.vimrc"
if [[ ! -f "$vim_config_file" && -f "$vim_source_file" ]]; then
copy_file_safe "$vim_source_file" "$vim_config_file"
fi
