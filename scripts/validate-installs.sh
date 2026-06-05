#!/usr/bin/env bash
# Verify tools and apps installed by src/scripts/install/* after master.sh / run-install.sh.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

export PATH="${HOME}/.cargo/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}"

# shellcheck source=lib/validate-common.sh
source "$(dirname "$0")/lib/validate-common.sh"

# --- Preflight (install/preflight) ---
section 'Preflight'
check_version curl curl --version
check_version wget wget --version

# --- Packages (install/packages) ---
section 'Packages'
if command -v batcat >/dev/null 2>&1; then
    check_version bat batcat --version
elif command -v bat >/dev/null 2>&1; then
    check_version bat bat --version
else
    fail bat 'batcat or bat'
fi
check_version eza eza --version
check_version fd fdfind --version
check_version git git --version
check_version htop htop --version
check_version jq jq --version
check_version fzf fzf --version
check_version zoxide zoxide --version
check_version whois whois --version
check_version tldr tldr --version
check_version tree-sitter tree-sitter --version
check_version pkg-config pkg-config --version
check_dpkg libsecret-1-0 libsecret-1-0
check_dpkg libsecret-1-dev libsecret-1-dev
check_version lazygit lazygit --version
check_version lazydocker lazydocker --version
check_version ripgrep rg --version
check_dpkg unzip unzip
check_version vim vim --version
check_version yazi yazi --version
check_version btop btop --version
check_version fastfetch fastfetch --version
check_version flatpak flatpak --version

# --- Apps (install/apps) ---
section 'Apps'
check_version brave brave-browser --version
check_version vlc vlc --version
check_version ffmpeg ffmpeg -version

check_version libreoffice libreoffice --version
check_dpkg keepassxc keepassxc
check_version flameshot flameshot --version
check_command redshift redshift

if command -v zoom >/dev/null 2>&1; then
    pass zoom "$(version_of zoom --version)"
elif flatpak_installed us.zoom.Zoom; then
    pass zoom 'flatpak: us.zoom.Zoom'
elif snap_installed zoom-client; then
    pass zoom 'snap: zoom-client'
else
    fail zoom 'deb, flatpak, or snap'
fi

if command -v balena-etcher >/dev/null 2>&1; then
    pass etcher "$(command -v balena-etcher)"
elif dpkg -s balena-etcher >/dev/null 2>&1; then
    pass etcher "$(dpkg -s balena-etcher 2>/dev/null | awk -F': ' '/^Version:/{print $2; exit}')"
else
    fail etcher 'balena-etcher package or command'
fi

# --- Dev (install/dev) ---
section 'Dev'
check_version node node --version
check_version npm npm --version
check_version python3 python3 --version
check_version go go version
check_version ruby ruby --version
check_version rustc rustc --version
check_version cargo cargo --version
check_version php php --version
check_version composer composer --version
check_version java java --version
if command -v julia >/dev/null 2>&1; then
    check_version julia julia --version
else
    pass julia 'optional (not in apt on all Ubuntu releases)'
fi
check_version lua lua5.4 -e 'print(_VERSION)'
check_version luarocks luarocks --version
check_version gcc gcc --version
if command -v gem >/dev/null 2>&1 && gem list solargraph -i >/dev/null 2>&1; then
  pass solargraph-gem 'gem: solargraph'
else
  fail solargraph-gem 'gem install --user-install solargraph'
fi
check_version docker docker --version
check_version docker-compose docker compose version
if docker info >/dev/null 2>&1; then
    pass docker-daemon 'docker info'
else
    fail docker-daemon 'docker info'
fi
check_version neovim nvim --version
check_version gh gh --version
check_version shellcheck shellcheck --version
if command -v semgrep >/dev/null 2>&1; then
    pass semgrep "$(version_of semgrep --version)"
else
    fail semgrep 'pip user install (~/.local/bin/semgrep)'
fi

if command -v vue >/dev/null 2>&1; then
    pass vue-cli "$(version_of vue --version)"
else
    fail vue-cli 'npm global @vue/cli'
fi

if command -v agent >/dev/null 2>&1; then
    pass cursor-agent "$(version_of agent --version)"
elif command -v cursor-agent >/dev/null 2>&1; then
    pass cursor-agent "$(version_of cursor-agent --version)"
else
    fail cursor-agent "agent CLI (cursor.com/install -> ${HOME}/.local/bin/agent)"
fi

check_version ollama ollama --version

if command -v bruno >/dev/null 2>&1; then
    if dpkg -s bruno >/dev/null 2>&1; then
        pass bruno "$(dpkg -s bruno 2>/dev/null | awk -F': ' '/^Version:/{print $2; exit}')"
    else
        pass bruno "$(command -v bruno)"
    fi
elif flatpak_installed com.usebruno.Bruno; then
    pass bruno 'flatpak: com.usebruno.Bruno'
else
    fail bruno 'apt or flatpak (com.usebruno.Bruno)'
fi

check_path nvm "$HOME/.nvm/nvm.sh"

# --- Security (install/apps + config/security) ---
section 'Security'
check_version nmap nmap --version
check_version exiftool exiftool -ver
check_version openvpn openvpn --version
check_dpkg ufw ufw
check_path ufw-docker /usr/local/bin/ufw-docker
check_dpkg signal-desktop signal-desktop

if command -v proton-pass >/dev/null 2>&1; then
    pass proton-pass "$(command -v proton-pass)"
elif dpkg -s proton-pass >/dev/null 2>&1; then
    pass proton-pass "$(dpkg -s proton-pass 2>/dev/null | awk -F': ' '/^Version:/{print $2; exit}')"
else
    fail proton-pass 'desktop .deb (proton-pass)'
fi

check_version pass-cli pass-cli --version

check_dpkg proton-vpn proton-vpn-gnome-desktop

if command -v zaproxy >/dev/null 2>&1; then
    pass zaproxy "$(command -v zaproxy)"
elif flatpak_installed org.zaproxy.ZAP; then
    pass zaproxy 'flatpak: org.zaproxy.ZAP'
elif snap_installed zaproxy; then
    pass zaproxy 'snap: zaproxy'
else
    fail zaproxy 'flatpak or snap'
fi

check_path hacking-payloads "$HOME/Hacking/PayloadsAllTheThings"
check_path hacking-seclists "$HOME/Hacking/SecLists"

check_dpkg gnome-tweaks gnome-tweaks
check_dpkg gnome-shell-extensions gnome-shell-extensions

# --- Shell (install/shell) ---
section 'Shell'
check_version zsh zsh --version
check_version tmux tmux -V
if command -v oh-my-posh >/dev/null 2>&1; then
    check_version oh-my-posh oh-my-posh --version
elif [[ -x "${HOME}/.local/bin/oh-my-posh" ]]; then
    pass oh-my-posh "$("${HOME}/.local/bin/oh-my-posh" --version 2>/dev/null | head -n1)"
else
    fail oh-my-posh 'oh-my-posh (~/.local/bin/oh-my-posh)'
fi
check_dpkg zsh-autosuggestions zsh-autosuggestions
check_dpkg zsh-syntax-highlighting zsh-syntax-highlighting
check_dpkg fonts-font-awesome fonts-font-awesome
check_dpkg fonts-firacode fonts-firacode
check_path meslo-nerd-font /usr/share/fonts/meslo-nerd-font

if command -v ghostty >/dev/null 2>&1; then
    pass ghostty "$(version_of ghostty --version)"
else
    fail ghostty 'ghostty terminal'
fi

finish_validation 'Install validation'
