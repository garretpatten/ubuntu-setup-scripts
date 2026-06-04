#!/usr/bin/env bash
# Verify config outcomes after master.sh / run-config.sh.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

# shellcheck source=lib/validate-common.sh
source "$(dirname "$0")/lib/validate-common.sh"

dotfiles="${PWD}/src/dotfiles"

section 'Dotfiles'
check_path dotfiles-nvim "$HOME/.config/nvim"
check_path dotfiles-fastfetch "$HOME/.config/fastfetch"
check_path dotfiles-btop "$HOME/.config/btop"
check_path dotfiles-zellij "$HOME/.config/zellij"
check_path dotfiles-tmux "$HOME/.config/tmux"
check_path dotfiles-ghostty "$HOME/.config/ghostty"
check_path dotfiles-path "$HOME/.dotfiles_path"
if [[ -f "$HOME/.dotfiles_path" ]]; then
    dotfiles_link=$(head -1 "$HOME/.dotfiles_path")
    if [[ "$dotfiles_link" == "$dotfiles" ]]; then
        pass dotfiles-path-value "$dotfiles_link"
    else
        fail dotfiles-path-value "expected: $dotfiles"
    fi
fi
check_path zshrc "$HOME/.zshrc"

section 'Home layout'
check_path screenshots-dir "$HOME/Pictures/Screenshots"
check_path projects-personal "$HOME/Projects/personal"
check_path hacking-dir "$HOME/Hacking"

section 'Git'
if git config --global user.name >/dev/null 2>&1; then
    pass git-user-name "$(git config --global user.name)"
else
    fail git-user-name 'git config --global user.name'
fi

section 'System'
if sudo ufw status 2>/dev/null | grep -qi 'Status: active'; then
    pass ufw-active 'ufw enabled'
else
    fail ufw-active 'ufw status active'
fi
check_path logind-lid /etc/systemd/logind.conf.d/50-lid.conf
check_path sysctl-keepalive /etc/sysctl.d/99-tcp-keepalive.conf
if [[ -f /etc/default/apport ]] && grep -q '^enabled=0' /etc/default/apport; then
    pass apport-disabled /etc/default/apport
else
    fail apport-disabled 'enabled=0 in /etc/default/apport'
fi

finish_validation 'Config validation'
