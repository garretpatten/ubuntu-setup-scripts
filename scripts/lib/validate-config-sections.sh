#!/usr/bin/env bash
# Shared config validation sections used by validate-config*.sh.
# Sourcing scripts are expected to source validate-common.sh first.

validate_config_dotfiles() {
    section 'Dotfiles'
    check_path dotfiles-nvim "$HOME/.config/nvim"
    check_path dotfiles-fastfetch "$HOME/.config/fastfetch"
    check_path dotfiles-btop "$HOME/.config/btop"
    check_path dotfiles-zellij "$HOME/.config/zellij"
    check_path dotfiles-tmux "$HOME/.config/tmux"
    check_path dotfiles-ghostty "$HOME/.config/ghostty"
    check_path dotfiles-zsh "$HOME/.config/zsh"
    check_path dotfiles-zsh-ubuntu "$HOME/.config/zsh/ubuntu.zsh"
    check_path zshrc "$HOME/.zshrc"
}

validate_config_home() {
    section 'Home layout'
    check_path screenshots-dir "$HOME/Pictures/Screenshots"
    check_path projects-personal "$HOME/Projects/personal"
    check_path hacking-dir "$HOME/Hacking"
}

validate_config_git() {
    section 'Git'
    credential_helper="/usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret"
    check_path git-credential-libsecret "$credential_helper"
    if git config --global --get credential.helper 2>/dev/null | grep -Fq "$credential_helper"; then
        pass git-credential-helper 'ready for next commit (name and PAT at push)'
    else
        fail git-credential-helper "git config --global credential.helper $credential_helper"
    fi
}

validate_config_ufw() {
    if sudo ufw status 2>/dev/null | grep -qi 'Status: active'; then
        pass ufw-active 'ufw enabled'
    else
        fail ufw-active 'ufw status active'
    fi
}

validate_config_system_core() {
    check_path logind-lid /etc/systemd/logind.conf.d/50-lid.conf
    check_path sysctl-keepalive /etc/sysctl.d/99-tcp-keepalive.conf
    if [[ -f /etc/default/apport ]] && grep -q '^enabled=0' /etc/default/apport; then
        pass apport-disabled /etc/default/apport
    else
        fail apport-disabled 'enabled=0 in /etc/default/apport'
    fi
}

validate_config_system() {
    section 'System'
    validate_config_ufw
    validate_config_system_core
}
