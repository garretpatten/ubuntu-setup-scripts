#!/bin/bash
# shellcheck source=../../utils.sh
source "$(dirname "$0")/../../utils.sh"
python_packages=("python3" "python3-pip" "python3-venv" "python3-dev")
install_apt_packages "${python_packages[@]}"
