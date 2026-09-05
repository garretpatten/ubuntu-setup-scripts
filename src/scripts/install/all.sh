#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/env.sh
source "$DIR/../lib/env.sh"
# shellcheck source=../lib/run.sh
source "$DIR/../lib/run.sh"
# shellcheck source=../lib/apt-packages.sh
source "$DIR/../lib/apt-packages.sh"
# shellcheck source=../lib/apt-repos.sh
source "$DIR/../lib/apt-repos.sh"
# shellcheck source=../lib/parallel.sh
source "$DIR/../lib/parallel.sh"

INSTALL_MODE="${1:-all}"
INSTALL_MODE="${INSTALL_MODE#-}"
INSTALL_MODE="${INSTALL_MODE#-}"

is_desktop() {
    [[ "$INSTALL_MODE" != cli ]]
}

PACKAGES=()
REPO_PIDS=()
ASYNC_PIDS=()
DEB_PIDS=()

REPO_SCRIPTS=(
    repos/setup.sh
)

ASYNC_SCRIPTS=(
    dev/nvm.sh
    dev/rustup.sh
    dev/cursor-cli.sh
    dev/ollama.sh
    dev/semgrep.sh
    dev/ruby-gems.sh
    dev/vue-cli.sh
    dev/language-servers.sh
    dev/go.sh
    shell/ghostty.sh
    shell/meslo-nerd-font.sh
    shell/oh-my-posh.sh
    apps/hacking-repos.sh
    apps/ufw-docker.sh
)

if is_desktop; then
    ASYNC_SCRIPTS+=(apps/snaps.sh)
fi

DEB_SCRIPTS=(
    apps/chrome.sh
    apps/etcher.sh
    apps/proton-pass.sh
)

echo "==> Installing base apt packages..."
install_apt_packages_from_file "$DIR/packages/base.packages"

echo "==> Installing shell apt packages..."
install_apt_packages_from_file "$DIR/packages/shell.packages"

if is_desktop; then
    echo "==> Installing media apt packages..."
    install_apt_packages_from_file "$DIR/packages/media.packages"

    echo "==> Installing desktop apt packages..."
    install_apt_packages_from_file "$DIR/packages/desktop.packages"

    echo "==> Installing productivity apt packages..."
    install_apt_packages_from_file "$DIR/packages/productivity.packages"
fi

echo "==> Setting up apt repositories..."
for script in "${REPO_SCRIPTS[@]}"; do
    REPO_PIDS+=("$(parallel_run_best_effort "$DIR/$script")")
done
parallel_wait_pids_best_effort "repository setup" "${REPO_PIDS[@]}"

if is_desktop; then
    run_script "$DIR/apps/protonvpn-install.sh"
fi
add_ppas_parallel "ppa:neovim-ppa/stable" "ppa:zhangsongcui3371/fastfetch"
sudo apt-get update -y || true

echo "==> Reconciling shell apt packages..."
install_apt_packages_from_file "$DIR/packages/shell.packages"

if is_desktop; then
    echo "==> Reconciling media apt packages..."
    install_apt_packages_from_file "$DIR/packages/media.packages"

    echo "==> Reconciling desktop apt packages..."
    install_apt_packages_from_file "$DIR/packages/desktop.packages"
fi

echo "==> Installing dev and language packages..."
install_apt_packages_from_file "$DIR/packages/lsp.packages"
install_apt_packages_from_file "$DIR/packages/dev.packages"

echo "==> Installing PPA and extra apt packages..."
install_apt_packages_from_files optional \
    "$DIR/packages/griffo.packages" \
    "$DIR/packages/fastfetch.packages"

if is_desktop; then
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections || true
    install_apt_packages_from_file "$DIR/packages/optional-desktop.packages" optional
fi

PACKAGES=()
if is_desktop; then
    append_packages_from_file "$DIR/packages/third-party-desktop.packages" PACKAGES
fi
append_packages_from_file "$DIR/packages/third-party-cli.packages" PACKAGES
if ! install_collected_packages optional; then
    install_collected_packages_individually optional
fi

install_apt_packages_from_file "$DIR/packages/lsp-optional.packages" optional

run_script "$DIR/dev/git-credential-libsecret.sh"

echo "==> Initializing asynchronous downloads..."
for script in "${ASYNC_SCRIPTS[@]}"; do
    ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/$script")")
done
parallel_wait_pids_best_effort "asynchronous tasks" "${ASYNC_PIDS[@]}"
echo "==> Asynchronous tasks completed."

if is_desktop; then
    echo "==> Installing .deb packages..."
    for script in "${DEB_SCRIPTS[@]}"; do
        DEB_PIDS+=("$(parallel_run_best_effort "$DIR/$script")")
    done
    parallel_wait_pids_best_effort ".deb package install" "${DEB_PIDS[@]}"
fi

run_script "$DIR/apps/pass-cli.sh"

run_script "$DIR/post-install/all.sh"
