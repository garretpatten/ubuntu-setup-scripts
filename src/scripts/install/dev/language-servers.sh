#!/bin/bash
sudo npm install -g bash-language-server pyright typescript-language-server yaml-language-server \
    --loglevel=error --no-update-notifier || true

if ! command -v lua-language-server >/dev/null 2>&1; then
    latest_url=$(curl -sL -o /dev/null -w '%{url_effective}' --connect-timeout 10 --max-time 30 \
        https://github.com/LuaLS/lua-language-server/releases/latest 2>/dev/null)
    lls_version=${latest_url##*/}
    if [[ -n "$lls_version" ]]; then
        lls_tar="/tmp/lua-language-server-${lls_version}-linux-x64.tar.gz"
        if curl -fsSL --connect-timeout 30 --max-time 300 \
            "https://github.com/LuaLS/lua-language-server/releases/download/${lls_version}/lua-language-server-${lls_version}-linux-x64.tar.gz" \
            -o "$lls_tar" 2>/dev/null; then
            lls_install_dir="$HOME/.local/share/lua-language-server"
            mkdir -p "$lls_install_dir"
            tar -xzf "$lls_tar" -C "$lls_install_dir" || true
            if [[ -f "$lls_install_dir/bin/lua-language-server" ]]; then
                mkdir -p "$HOME/.local/bin"
                cat > "$HOME/.local/bin/lua-language-server" <<EOF
#!/bin/bash
exec "$lls_install_dir/bin/lua-language-server" "\$@"
EOF
                chmod +x "$HOME/.local/bin/lua-language-server" || true
            fi
        fi
    fi
fi
