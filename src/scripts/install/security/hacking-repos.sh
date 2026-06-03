#!/bin/bash
mkdir -p "$HOME/Hacking"
[[ -d "$HOME/Hacking/PayloadsAllTheThings" ]] || git clone https://github.com/swisskyrepo/PayloadsAllTheThings "$HOME/Hacking/PayloadsAllTheThings" || true
[[ -d "$HOME/Hacking/SecLists" ]] || git clone https://github.com/danielmiessler/SecLists "$HOME/Hacking/SecLists" || true
