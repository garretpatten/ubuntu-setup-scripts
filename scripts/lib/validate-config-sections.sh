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

validate_config_tmux() {
    section 'Tmux'
    check_path tmux-tpm "$HOME/.tmux/plugins/tpm/tpm"
    check_path tmux-plugin-resurrect "$HOME/.tmux/plugins/tmux-resurrect"
    check_path tmux-plugin-continuum "$HOME/.tmux/plugins/tmux-continuum"
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

validate_config_gnome_workspaces() {
    local dir
    dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # shellcheck source=../../src/scripts/lib/gnome-session.sh
    source "$dir/../../src/scripts/lib/gnome-session.sh"

    if ! gnome_session_active 2>/dev/null; then
        pass gnome-workspaces 'skipped: no GNOME session'
        return 0
    fi
    if ! command -v gsettings >/dev/null 2>&1 || [[ ! -S "/run/user/$(id -u)/bus" ]]; then
        pass gnome-workspaces 'skipped: gsettings unavailable'
        return 0
    fi

    section 'GNOME workspaces'

    if [[ "$(gsettings get org.gnome.mutter dynamic-workspaces 2>/dev/null)" == 'false' ]]; then
        pass workspaces-static 'dynamic-workspaces false'
    else
        fail workspaces-static 'expected org.gnome.mutter dynamic-workspaces false'
    fi

    if [[ "$(gsettings get org.gnome.desktop.wm.preferences num-workspaces 2>/dev/null)" == '6' ]]; then
        pass workspaces-count 'num-workspaces 6'
    else
        fail workspaces-count 'expected org.gnome.desktop.wm.preferences num-workspaces 6'
    fi

    local i missing=''
    for i in 1 2 3 4 5 6; do
        if ! gsettings get org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" 2>/dev/null | grep -qF "<Control>$i"; then
            missing="$missing $i"
        fi
    done
    if [[ -z "$missing" ]]; then
        pass workspace-keybindings 'switch-to-workspace-1..6 -> Ctrl+1..6'
    else
        fail workspace-keybindings "missing Ctrl bindings for workspace(s):$missing"
    fi
}

validate_config_system() {
    section 'System'
    validate_config_ufw
    validate_config_system_core
}
