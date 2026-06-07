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

PACKAGES=()
REPO_PIDS=()
ASYNC_PIDS=()

REPO_SCRIPTS=(
    repos/setup.sh
)

ASYNC_SCRIPTS=(
    apps/snaps.sh
    dev/nvm.sh
    dev/rustup.sh
    dev/cursor-cli.sh
    dev/ollama.sh
    dev/semgrep.sh
    dev/ruby-gems.sh
    dev/git-credential-libsecret.sh
    shell/ghostty.sh
    shell/meslo-nerd-font.sh
    shell/oh-my-posh.sh
    apps/hacking-repos.sh
    apps/ufw-docker.sh
)

echo "==> Installing main apt packages..."
for list in base shell media desktop productivity; do
    install_apt_packages_from_file "$DIR/packages/${list}.packages"
done

echo "==> Setting up apt repositories..."
for script in "${REPO_SCRIPTS[@]}"; do
    REPO_PIDS+=("$(parallel_run_best_effort "$DIR/$script")")
done
parallel_wait_pids_best_effort "repository setup" "${REPO_PIDS[@]}"

run_script "$DIR/apps/protonvpn-install.sh"
add_ppas_parallel "ppa:neovim-ppa/stable" "ppa:zhangsongcui3371/fastfetch"
sudo apt-get update -y || true

echo "==> Installing dev and language packages..."
for list in dev lsp; do
    install_apt_packages_from_file "$DIR/packages/${list}.packages"
done

echo "==> Installing PPA and extra apt packages..."
install_apt_packages_from_file "$DIR/packages/griffo.packages" optional
install_apt_packages_from_file "$DIR/packages/fastfetch.packages" optional
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ubuntu-restricted-extras || true

PACKAGES=()
append_packages_from_file "$DIR/packages/third-party.packages" PACKAGES
if ! install_collected_packages optional; then
    install_collected_packages_individually optional
fi

install_apt_packages_from_file "$DIR/packages/lsp-optional.packages" optional

run_script "$DIR/dev/vue-cli.sh"

echo "==> Initializing asynchronous downloads..."
for script in "${ASYNC_SCRIPTS[@]}"; do
    ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/$script")")
done
parallel_wait_pids_best_effort "asynchronous tasks" "${ASYNC_PIDS[@]}"
echo "==> Asynchronous tasks completed."

echo "==> Installing .deb packages..."
run_script "$DIR/apps/etcher.sh"
run_script "$DIR/apps/proton-pass.sh"

run_script "$DIR/post-install/all.sh"
