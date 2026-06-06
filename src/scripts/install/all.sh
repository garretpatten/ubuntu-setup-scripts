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

run_script "$DIR/flatpak.sh"

echo "==> Setting up apt repositories..."
REPO_PIDS+=("$(parallel_run_script "$DIR/apps/brave-browser.sh")")
REPO_PIDS+=("$(parallel_run_script "$DIR/apps/signal-desktop.sh")")
REPO_PIDS+=("$(parallel_run_script "$DIR/apps/bruno.sh")")
REPO_PIDS+=("$(parallel_run_script "$DIR/apps/protonvpn.sh")")
REPO_PIDS+=("$(parallel_run_script "$DIR/dev/nodesource-nodejs.sh")")
REPO_PIDS+=("$(parallel_run_script "$DIR/dev/docker.sh")")
REPO_PIDS+=("$(parallel_run_script "$DIR/griffo.sh")")
parallel_wait_pids "repository setup" "${REPO_PIDS[@]}"

add_ppas_parallel "ppa:neovim-ppa/stable" "ppa:zhangsongcui3371/fastfetch"
sudo apt-get update -y || true

echo "==> Installing native packages (consolidated)..."
for list in base shell media desktop productivity dev lsp; do
    append_packages_from_file "$DIR/packages/${list}.packages" PACKAGES
done
install_collected_packages

echo "==> Installing PPA and third-party apt packages..."
PACKAGES=()
for list in griffo fastfetch; do
    append_packages_from_file "$DIR/packages/${list}.packages" PACKAGES
done
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections || true
PACKAGES+=(ubuntu-restricted-extras)
install_collected_packages optional

PACKAGES=()
append_packages_from_file "$DIR/packages/third-party.packages" PACKAGES
install_collected_packages_individually optional

PACKAGES=()
append_packages_from_file "$DIR/packages/lsp-optional.packages" PACKAGES
install_collected_packages optional

run_script "$DIR/dev/vue-cli.sh"

echo "==> Initializing asynchronous downloads..."
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/dev/nvm.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/dev/rustup.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/dev/cursor-cli.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/dev/ollama.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/dev/semgrep.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/dev/ruby-gems.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/dev/git-credential-libsecret.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/shell/ghostty.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/shell/meslo-nerd-font.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/shell/oh-my-posh.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/apps/hacking-repos.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/apps/ufw-docker.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/apps/zoom.sh")")
ASYNC_PIDS+=("$(parallel_run_best_effort "$DIR/apps/etcher.sh")")

parallel_wait_pids "asynchronous tasks" "${ASYNC_PIDS[@]}"
echo "==> Asynchronous tasks completed."

run_script "$DIR/apps/zoom-install.sh"
run_script "$DIR/apps/etcher-install.sh"
run_script "$DIR/apps/proton-pass.sh"
run_script "$DIR/apps/bruno-fallback.sh"
run_script "$DIR/apps/zoom-fallback.sh"
run_script "$DIR/apps/zaproxy.sh"
run_script "$DIR/btop.sh"
run_script "$DIR/post-install/all.sh"
