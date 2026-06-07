#!/bin/bash

# shellcheck source=../../lib/apt-maintain.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../lib/apt-maintain.sh"

apt_maintain_update
