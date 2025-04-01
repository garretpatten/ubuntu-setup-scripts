#!/bin/bash

bash "$workingDirectory/src/scripts/pre-install.sh"

# Home directory customization
bash "$(pwd)/src/scripts/organizeHome.sh"

# CLI tools
bash "$(pwd)/src/scripts/cli.sh"

# Dev tools
bash "$(pwd)/src/scripts/dev.sh"

# Browsers, streaming, and video applications
bash "$(pwd)/src/scripts/media.sh"

# Security and penetration testing utilities
bash "$(pwd)/src/scripts/security.sh"

# Shell setup
bash "$(pwd)/src/scripts/shell.sh"

bash "$workingDirectory/src/scripts/post-install.sh" "$workingDirectory"
