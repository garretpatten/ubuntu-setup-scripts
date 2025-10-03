#!/bin/bash

# Shell and Terminal Setup Script
# Installs and configures shells, terminal emulators, fonts, and plugins
# Author: Garret Patten

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

# Install shells and terminal emulators
install_shells_and_terminals() {
    log_info "Installing shells and terminal emulators..."

    # Define shell and terminal packages
    local shell_packages=(
        "zsh"           # Z Shell
        "alacritty"     # GPU-accelerated terminal emulator
        "tmux"          # Terminal multiplexer
        "powerline"     # Powerline status line for terminals
    )

    # Install packages in batch
    install_apt_packages "${shell_packages[@]}"
}

# Install fonts for better terminal experience
install_fonts() {
    log_info "Installing terminal fonts..."

    # Define font packages
    local font_packages=(
        "fonts-font-awesome"     # Font Awesome icons
        "fonts-firacode"         # Fira Code programming font
        "fonts-freefont-ttf"     # Free TTF fonts
        "fonts-powerline"        # Powerline fonts for status bars
        "fonts-noto-color-emoji" # Color emoji support
    )

    # Install font packages in batch
    install_apt_packages "${font_packages[@]}"

        # Install Meslo Nerd Font for Oh My Posh themes
    install_meslo_nerd_font() {
        local font_dir="/usr/share/fonts/meslo-nerd-font"

        if [[ ! -d "$font_dir" ]]; then
            log_info "Installing Meslo Nerd Font for Oh My Posh themes..."

            # Create temporary directory for font download
            local temp_font_dir="$TEMP_DIR/meslo-font"
            ensure_directory "$temp_font_dir"

            # Download Meslo Nerd Font
            local meslo_zip="$temp_font_dir/Meslo.zip"
            local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip"

            if download_file_safe "$download_url" "$meslo_zip"; then
                # Create system font directory
                sudo mkdir -p "$font_dir"

                # Extract fonts to temporary directory first
                if unzip -q "$meslo_zip" -d "$temp_font_dir"; then
                    # Move all font files to system font directory
                    sudo mv "$temp_font_dir"/*.ttf "$font_dir/" 2>/dev/null || true
                    sudo mv "$temp_font_dir"/*.otf "$font_dir/" 2>/dev/null || true

                    # Set proper permissions
                    sudo chmod 644 "$font_dir"/*.ttf 2>/dev/null || true
                    sudo chmod 644 "$font_dir"/*.otf 2>/dev/null || true

                    log_success "Meslo Nerd Font installed successfully to $font_dir"
                else
                    log_error "Failed to extract Meslo Nerd Font"
                    return 1
                fi
            else
                log_error "Failed to download Meslo Nerd Font"
                return 1
            fi
        else
            log_info "Meslo Nerd Font is already installed"
        fi
    }

    # Install Meslo Nerd Font
    install_meslo_nerd_font

    # Update font cache
    log_info "Updating font cache..."
    fc-cache -fv || log_warning "Failed to update font cache"
}

# Install shell plugins and enhancements
install_shell_plugins() {
    log_info "Installing shell plugins and enhancements..."

    # Define shell plugin packages
    local plugin_packages=(
        "zsh-autosuggestions"       # Fish-like autosuggestions for zsh
        "zsh-syntax-highlighting"   # Syntax highlighting for zsh
    )

    # Install plugin packages in batch
    install_apt_packages "${plugin_packages[@]}"

    # Install Oh My Posh (modern prompt theme engine)
    install_oh_my_posh() {
        if ! is_installed "oh-my-posh"; then
            log_info "Installing Oh My Posh prompt theme engine..."

            # Download and install Oh My Posh
            local omp_install_script="$TEMP_DIR/oh-my-posh-install.sh"
            download_file_safe "https://ohmyposh.dev/install.sh" "$omp_install_script"
            bash "$omp_install_script" -s -- --user

            log_success "Oh My Posh installed successfully"
        else
            log_info "Oh My Posh is already installed"
        fi

        # Install Oh My Posh themes
        install_oh_my_posh_themes() {
            local themes_dir="/usr/share/oh-my-posh/themes"

            if [[ ! -d "$themes_dir" ]] || [[ -z "$(ls -A "$themes_dir" 2>/dev/null)" ]]; then
                log_info "Installing Oh My Posh themes..."

                # Create themes directory
                sudo mkdir -p "$themes_dir"

                # Clone Oh My Posh repository to get themes
                local temp_repo_dir="$TEMP_DIR/oh-my-posh-repo"
                if clone_repository_safe "https://github.com/JanDeDobbeleer/oh-my-posh.git" "$temp_repo_dir"; then
                    # Copy themes to system directory
                    if [[ -d "$temp_repo_dir/themes" ]]; then
                        sudo cp -r "$temp_repo_dir/themes/"* "$themes_dir/"

                        # Set proper permissions
                        sudo chmod -R 755 "$themes_dir"
                        sudo chown -R root:root "$themes_dir"

                        log_success "Oh My Posh themes installed successfully to $themes_dir"
                    else
                        log_warning "Themes directory not found in Oh My Posh repository"
                    fi
                else
                    log_warning "Failed to clone Oh My Posh repository for themes"
                fi
            else
                log_info "Oh My Posh themes are already installed"
            fi
        }

        install_oh_my_posh_themes
    }

    install_oh_my_posh
}

# Configure terminal applications
configure_terminal_applications() {
    log_info "Configuring terminal applications..."

    # Configure Alacritty terminal emulator
    configure_alacritty() {
        local alacritty_config_dir="$HOME/.config/alacritty"
        local alacritty_source_dir="$PROJECT_ROOT/src/dotfiles/alacritty"

        if [[ ! -d "$alacritty_config_dir" ]]; then
            log_info "Configuring Alacritty terminal emulator..."
            ensure_directory "$alacritty_config_dir"

            # Clone Alacritty themes repository
            local themes_dir="$alacritty_config_dir/themes"
            if [[ ! -d "$themes_dir" ]]; then
                clone_repository_safe "https://github.com/alacritty/alacritty-theme" "$themes_dir"
            fi

            # Copy configuration file if available
            if [[ -f "$alacritty_source_dir/alacritty.toml" ]]; then
                copy_file_safe "$alacritty_source_dir/alacritty.toml" "$alacritty_config_dir/alacritty.toml"
            else
                log_warning "Alacritty configuration source not found: $alacritty_source_dir/alacritty.toml"
                # Create a basic configuration file
                cat > "$alacritty_config_dir/alacritty.toml" << 'EOF'
# Alacritty Configuration
[window]
opacity = 0.95

[font]
size = 12.0

[font.normal]
family = "Fira Code"
style = "Regular"

[colors]
# Import a theme (uncomment to use)
# import = ["~/.config/alacritty/themes/dracula.toml"]
EOF
                log_info "Created basic Alacritty configuration"
            fi
        else
            log_info "Alacritty is already configured"
        fi
    }

    # Configure Tmux terminal multiplexer
    configure_tmux() {
        local tmux_config_file="$HOME/.tmux.conf"
        local tmux_source_file="$PROJECT_ROOT/src/dotfiles/tmux/.tmux.conf"

        if [[ ! -f "$tmux_config_file" ]]; then
            log_info "Configuring Tmux..."

            if [[ -f "$tmux_source_file" ]]; then
                copy_file_safe "$tmux_source_file" "$tmux_config_file"
            else
                log_warning "Tmux configuration source not found: $tmux_source_file"
                # Create a basic tmux configuration
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
                log_info "Created basic Tmux configuration"
            fi
        else
            log_info "Tmux is already configured"
        fi
    }

    # Configure Z Shell
    configure_zsh() {
        local zsh_config_file="$HOME/.zshrc"
        local zsh_source_file="$PROJECT_ROOT/src/dotfiles/oh-my-posh/.zshrc"

        if [[ ! -f "$zsh_config_file" ]]; then
            log_info "Configuring Z Shell..."

            if [[ -f "$zsh_source_file" ]]; then
                copy_file_safe "$zsh_source_file" "$zsh_config_file"
            else
                log_warning "Zsh configuration source not found: $zsh_source_file"
                # Create a basic zsh configuration
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
                log_info "Created basic Zsh configuration"
            fi
        else
            log_info "Zsh is already configured"
        fi
    }

    configure_alacritty
    configure_tmux
    configure_zsh
}

# Change default shell to zsh
change_default_shell() {
    log_info "Changing default shell to zsh..."

    # Get zsh path
    local zsh_path
    zsh_path="$(which zsh)"

    if [[ -n "$zsh_path" ]]; then
        # Change shell for current user
        if [[ "$SHELL" != "$zsh_path" ]]; then
            log_info "Changing default shell for current user to zsh..."
            chsh -s "$zsh_path" || log_warning "Failed to change user shell to zsh"
        else
            log_info "Default shell is already zsh"
        fi

        # Change shell for root (optional, with warning)
        log_info "Note: Root shell change skipped for security reasons"
        log_info "To change root shell manually: sudo chsh -s $zsh_path"
    else
        log_error "Zsh not found, cannot change default shell"
        return 1
    fi
}

# Main function
main() {
    log_info "Starting shell and terminal setup..."

    # Update package cache
    update_apt_cache

    # Install and configure components
    install_shells_and_terminals
    install_fonts
    install_shell_plugins
    configure_terminal_applications
    change_default_shell

    log_success "Shell and terminal setup completed!"
    log_info "Please log out and log back in for shell changes to take effect"
    log_info "You may need to restart your terminal to see font changes"
}

# Execute main function
main "$@"

