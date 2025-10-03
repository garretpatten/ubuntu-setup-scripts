#!/bin/bash

# Development Tools Installation Script
# Installs programming languages, frameworks, and development tools
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Install programming language runtimes
install_runtimes() {
    log_info "Installing programming language runtimes..."

    # Install Node.js via NodeSource repository (more reliable than snap)
    install_nodejs() {
        if ! is_installed "node"; then
            log_info "Installing Node.js and npm..."

            # Download and verify NodeSource setup script
            local node_setup_script="$TEMP_DIR/nodejs_setup.sh"
            download_file_safe "https://deb.nodesource.com/setup_lts.x" "$node_setup_script"

            # Execute the setup script
            sudo bash "$node_setup_script"
            update_apt_cache

            # Install Node.js and npm
            install_apt_packages "nodejs"

            # Install NVM for version management
            if [[ ! -d "$HOME/.nvm" ]]; then
                log_info "Installing Node Version Manager (NVM)..."
                local nvm_install_script="$TEMP_DIR/nvm_install.sh"
                download_file_safe "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh" "$nvm_install_script"
                bash "$nvm_install_script"
            fi
        else
            log_info "Node.js is already installed"
        fi
    }

    # Install Python and pip
    install_python() {
        local python_packages=(
            "python3"
            "python3-pip"
            "python3-venv"
            "python3-dev"
        )

        log_info "Installing Python development environment..."
        install_apt_packages "${python_packages[@]}"
    }

    install_nodejs
    install_python
}

# Install development frameworks
install_frameworks() {
    log_info "Installing development frameworks..."

    # Install Vue.js CLI globally if Node.js is available
    if is_installed "npm" && [[ ! -f "/usr/local/bin/vue" ]]; then
        log_info "Installing Vue.js CLI..."
        sudo npm install -g @vue/cli
        log_success "Vue.js CLI installed"
    fi
}

# Install Docker and container tools
install_docker() {
    log_info "Installing Docker and container tools..."

    if ! is_installed "docker"; then
        log_info "Installing Docker..."

        # Install Docker dependencies
        local docker_deps=(
            "apt-transport-https"
            "ca-certificates"
            "software-properties-common"
            "gnupg"
            "lsb-release"
        )
        install_apt_packages "${docker_deps[@]}"

        # Add Docker's official GPG key
        if [[ ! -f "/usr/share/keyrings/docker-archive-keyring.gpg" ]]; then
            log_info "Adding Docker GPG key..."
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
                sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        fi

        # Add Docker repository
        if ! grep -q "download.docker.com" /etc/apt/sources.list.d/*.list 2>/dev/null; then
            log_info "Adding Docker repository..."
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            update_apt_cache
        fi

        # Install Docker packages
        local docker_packages=(
            "docker-ce"
            "docker-ce-cli"
            "containerd.io"
            "docker-compose-plugin"
        )
        install_apt_packages "${docker_packages[@]}"

        # Pull common base images
        log_info "Pulling common Docker base images..."
        docker image pull ubuntu:latest || log_warning "Failed to pull Ubuntu image"
        docker image pull alpine:latest || log_warning "Failed to pull Alpine image"

        log_success "Docker installation completed"
    else
        log_info "Docker is already installed"
    fi
}

# Install development tools
install_dev_tools() {
    log_info "Installing development tools..."

    # Define development tools to install
    local dev_tools=(
        "gh"            # GitHub CLI
        "neovim"        # Modern Vim
        "shellcheck"    # Shell script linter
        "git"           # Version control (if not already installed)
    )

    # Install development tools in batch
    install_apt_packages "${dev_tools[@]}"

    # Install Neovim package manager (Packer)
    install_neovim_packer() {
        local packer_dir="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
        if [[ ! -d "$packer_dir" ]]; then
            log_info "Installing Neovim Packer plugin manager..."
            clone_repository_safe "https://github.com/wbthomason/packer.nvim" "$packer_dir" "1"
        else
            log_info "Neovim Packer is already installed"
        fi
    }

    # Install Postman via Flatpak
    install_postman() {
        if ! is_flatpak_installed "com.getpostman.Postman"; then
            log_info "Installing Postman via Flatpak..."
            flatpak install -y flathub com.getpostman.Postman
            log_success "Postman installed"
        else
            log_info "Postman is already installed"
        fi
    }

    # Install Semgrep for code analysis
    install_semgrep() {
        if ! is_installed "semgrep"; then
            log_info "Installing Semgrep code analysis tool..."
            python3 -m pip install --user semgrep
            log_success "Semgrep installed"
        else
            log_info "Semgrep is already installed"
        fi
    }

    # Install Sourcegraph CLI
    install_sourcegraph_cli() {
        local src_binary="/usr/local/bin/src"
        if [[ ! -f "$src_binary" ]]; then
            log_info "Installing Sourcegraph CLI..."
            local temp_src="$TEMP_DIR/src"
            download_file_safe "https://sourcegraph.com/.api/src-cli/src_linux_amd64" "$temp_src"
            sudo mv "$temp_src" "$src_binary"
            sudo chmod +x "$src_binary"
            log_success "Sourcegraph CLI installed"
        else
            log_info "Sourcegraph CLI is already installed"
        fi
    }

    install_neovim_packer
    install_postman
    install_semgrep
    install_sourcegraph_cli
}

# Configure development tools
configure_dev_tools() {
    log_info "Configuring development tools..."

    # Configure Git with user information
    configure_git() {
        if [[ ! -f "$HOME/.gitconfig" ]]; then
            log_info "Configuring Git with default settings..."
            git config --global credential.helper store
            git config --global http.postBuffer 157286400
            git config --global pack.window 1
            git config --global user.email "garret.patten@proton.me"
            git config --global user.name "Garret Patten"
            git config --global pull.rebase false
            git config --global init.defaultBranch main
            log_success "Git configured successfully"
        else
            log_info "Git is already configured"
        fi
    }

    # Configure Neovim
    configure_neovim() {
        local nvim_config_dir="$HOME/.config/nvim"
        local nvim_source_dir="$PROJECT_ROOT/src/dotfiles/nvim"

        if [[ ! -d "$nvim_config_dir" && -d "$nvim_source_dir" ]]; then
            log_info "Configuring Neovim..."
            ensure_directory "$nvim_config_dir"
            cp -r "$nvim_source_dir/"* "$nvim_config_dir/" && \
                log_success "Neovim configured successfully" || \
                log_error "Failed to configure Neovim"
        else
            log_info "Neovim configuration already exists or source not found"
        fi
    }

    # Configure Vim
    configure_vim() {
        local vim_config_file="$HOME/.vimrc"
        local vim_source_file="$PROJECT_ROOT/src/dotfiles/vim/.vimrc"

        if [[ ! -f "$vim_config_file" && -f "$vim_source_file" ]]; then
            log_info "Configuring Vim..."
            copy_file_safe "$vim_source_file" "$vim_config_file"
        else
            log_info "Vim configuration already exists or source not found"
        fi
    }

    configure_git
    configure_neovim
    configure_vim
}

# Main function
main() {
    log_info "Starting development tools installation..."

    # Update package cache
    update_apt_cache

    # Install components
    install_runtimes
    install_frameworks
    install_docker
    install_dev_tools
    configure_dev_tools

    log_success "Development tools installation completed!"
    log_info "Note: You may need to log out and back in for Docker group permissions to take effect"
}

# Execute main function
main "$@"
