# Ubuntu Setup Scripts

A comprehensive collection of bash scripts for setting up Ubuntu development environments with security tools, productivity applications, and system configurations. These scripts are designed for reliable execution at scale across Ubuntu-based Linux distributions.

## ✨ Features

- **🔧 Automated Setup**: Complete system configuration with a single command
- **🛡️ Security First**: Built-in security tools, firewall configuration, and safe installation practices
- **⚡ Optimized Performance**: Batch installations and smart caching for faster execution
- **🔄 Idempotent**: Safe to run multiple times without issues
- **📝 Comprehensive Logging**: Detailed progress tracking and error reporting
- **🎯 Modular Design**: Run individual components or the complete setup

## 🚀 Quick Start

### Prerequisites

- Ubuntu 20.04+ or Ubuntu-based distribution
- Internet connection
- Sudo privileges

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/garretpatten/ubuntu-setup-scripts
cd ubuntu-setup-scripts
```

2. **Update submodules** (for dotfiles)

```bash
git submodule update --init --remote --recursive src/dotfiles/
```

3. **Make scripts executable**

```bash
chmod +x src/scripts/*.sh
```

4. **Run the complete setup**

```bash
./src/scripts/master.sh
```

### Individual Component Installation

You can also run individual setup scripts:

```bash
# Apply only desktop / system preferences (GNOME; Ubuntu Desktop session recommended)
./src/scripts/system-config.sh

# Install only development tools
./src/scripts/dev.sh

# Install only security tools
./src/scripts/security.sh

# Install only media applications
./src/scripts/media.sh
```

## 📋 What Gets Installed

### 🏠 **System Setup** (`organizeHome.sh`)

- Removes unused default directories (Music, Public, Templates)
- Creates organized project structure (Projects, Hacking, Scripts, Tools)
- Sets up development workspace with proper permissions

### ⚙️ **Desktop & system preferences** (`system-config.sh`)

- **GNOME (when a desktop session is available)**: Dark appearance, reduced UI animations, clock with date/weekday, optional battery percentage hidden
- **Input**: Classic (non-natural) scrolling for touchpad and mouse; fast key repeat
- **Files (Nautilus)**: Hidden files, list view, path in the location bar, tighter local search scope
- **Screenshots**: Save to `~/Pictures/Screenshots` (folder created if needed); no window shadow when supported
- **Dock**: Dash to Dock autohide with short delays (Ubuntu’s default extension)
- **Night Light**: Enabled with automatic schedule and warm temperature (pick **Night Light or Redshift** from `productivity.sh`, not both)
- **Session & lock**: Screen lock enabled; short delay before lock after idle
- **Privacy**: Fewer recent-file traces; old temp file cleanup
- **APT**: `unattended-upgrades` installed; periodic unattended upgrades enabled when `20auto-upgrades` is not already present
- **System (sudo)**: Guest login disabled via GDM when applicable; Apport crash UI toned down; `logind` lid behavior; optional TCP keepalive sysctl tuning

Headless or minimal installs skip `gsettings` steps; run from a logged-in Ubuntu Desktop session for full effect.

### 🛠️ **CLI Tools** (`cli.sh`)

- **Package Managers**: Flatpak with Flathub repository
- **Essential Tools**: bat, curl, eza, fastfetch, fd-find, git, htop, jq, ripgrep, vim, wget

### 💻 **Development Environment** (`dev.sh`)

- **Languages**: Node.js (LTS), Python 3, NVM
- **Frameworks**: Vue.js CLI
- **Tools**: Docker, GitHub CLI, Neovim, Postman, Semgrep, Shellcheck, Sourcegraph CLI
- **Configuration**: Git setup, Neovim/Vim configurations

### 🎬 **Media Applications** (`media.sh`)

- **Browsers**: Brave Browser
- **Media Players**: VLC, Spotify
- **Codecs**: Ubuntu restricted extras, FFmpeg, GStreamer plugins

### 📊 **Productivity Tools** (`productivity.sh`)

- **Office Suite**: LibreOffice with modern themes
- **Communication**: Zoom
- **Note-taking**: Notion, Standard Notes
- **Utilities**: Balena Etcher, Flameshot, KeePassXC, Redshift

### 🔒 **Security Tools** (`security.sh`)

- **Authentication**: Proton Pass (desktop + CLI)
- **Defense**: UFW firewall, OpenVPN
- **VPN**: ProtonVPN with system tray integration
- **Communication**: Signal Messenger
- **Penetration Testing**: Nmap, OWASP ZAP, ExifTool
- **Resources**: PayloadsAllTheThings, SecLists repositories

### 🐚 **Shell & Terminal** (`shell.sh`)

- **Shells**: Zsh with autosuggestions and syntax highlighting
- **Terminal**: Ghostty with themes, Tmux multiplexer
- **Fonts**: Fira Code, Font Awesome, Powerline fonts
- **Prompt**: Oh My Posh theme engine

## 🔧 System Configurations

The scripts automatically configure:

- **Desktop & session** (`system-config.sh`): GNOME preferences (appearance, input, Files, Dock, Night Light, lock/privacy), unattended security updates, and related system defaults
- **Git**: User information and performance settings
- **Firewall**: UFW with secure defaults (deny incoming, allow outgoing)
- **Docker**: Service enablement and user group management
- **Shell**: Zsh as default with custom configurations
- **Terminal**: Ghostty, Tmux, and shell plugin setup
- **Timezone & APT**: Timezone when still UTC (`pre-install.sh`); automatic updates via `unattended-upgrades` where configured

## 📊 Monitoring & Logs

After installation, check:

- **Error Log**: `setup_errors.log` - Centralized error tracking
- **Summary Report**: `setup_summary.txt` - Installation status overview
- **Console Output**: Real-time progress with color-coded messages

## ⚠️ Post-Installation Notes

1. **Restart Required**: Log out and back in for shell and group changes
2. **GNOME / desktop**: Some `system-config.sh` preferences apply fully after re-login or when running the script from an active desktop session
3. **Docker**: User added to docker group (logout required for effect)
4. **Firewall**: UFW enabled with SSH access allowed
5. **Night Light vs Redshift**: If you use GNOME Night Light from `system-config.sh`, disable or uninstall Redshift from `productivity.sh` to avoid conflicting color temperature
6. **Manual Setup**: Some applications (like 1Password, ProtonVPN) may require additional configuration

## 🔍 Troubleshooting

### Common Issues

**Script fails with permission errors:**

```bash
# Ensure scripts are executable
chmod +x src/scripts/*.sh
```

**Package installation fails:**

```bash
# Update package lists manually
sudo apt update
# Then re-run the script
```

**Docker commands require sudo:**

```bash
# Log out and back in, or run:
newgrp docker
```

**Shell doesn't change to Zsh:**

```bash
# Manually change shell
chsh -s $(which zsh)
# Then log out and back in
```

### Getting Help

- Check `setup_errors.log` for detailed error information
- Review `setup_summary.txt` for installation status
- Ensure you're running on a supported Ubuntu version (20.04+)
- Verify internet connection for package downloads

## 🛡️ Security Features

- **Hash verification** for all downloaded packages
- **GPG key verification** for third-party repositories
- **Automatic firewall configuration** with secure defaults
- **Safe temporary file handling** with automatic cleanup
- **Principle of least privilege** for directory permissions

## Maintainers

[@garretpatten](https://github.com/garretpatten/)

_For questions, bug reports, or feature requests, please open an issue on this repository or contact the maintainer directly._

## License

This project is licensed under the [MIT License](./LICENSE).
