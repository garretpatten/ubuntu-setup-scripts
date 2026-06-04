# Ubuntu setup scripts

Provisioning for a personal Ubuntu desktop: per-app install scripts under
`src/scripts/install/`, dotfiles and system config under `src/scripts/config/`,
orchestrated by `master.sh`.

```bash
cd src/scripts
bash master.sh          # install + config
# or
bash run-install.sh     # install only
bash run-config.sh      # config only
```

CI runs `master.sh` on `ubuntu-latest`, then `scripts/validate-installs.sh` to
check that expected binaries and packages are present.

## Package manager preference

Install scripts prefer, in order:

1. **apt** (official `.deb` / apt repositories)
2. **Flatpak** (Flathub)
3. **AppImage** or upstream static/binary releases
4. **snap** (only when no practical alternative)

## What gets installed

### CLI (`install/cli/`)

Apt tools are listed one per line in `*.packages` files (Omarchy-style) and
installed by the matching script (`grep` skips `#` comments and blank lines).

| File | Tool(s) | Method |
|------|---------|--------|
| `cli.packages` | bat, curl, eza, fzf, jq, ripgrep, tree-sitter-cli, tealdeer (`tldr`), zoxide, whois, unzip, libsecret, gcc, pkg-config, … | apt (universe) |
| `yazi.packages` | yazi, lazygit, lazydocker | apt ([debian.griffo.io](https://debian.griffo.io/apt)) |
| `btop.packages` | btop | apt (Ubuntu ≥ 22.04), else GitHub musl binary, else snap |
| `fastfetch.packages` | fastfetch | apt (PPA) |
| — | Flathub remotes | `flatpak.sh` (after `flatpak` from `cli.packages`) |

### Media (`install/media/`)

| App | Method |
|-----|--------|
| Brave Browser | apt (vendor repo) |
| VLC | apt |
| ffmpeg, ubuntu-restricted-extras | apt |

### Desktop (`install/desktop/`)

| Tool | Method |
|------|--------|
| GNOME Tweaks, shell extensions | apt (`gnome.packages`) |

### Productivity (`install/productivity/`)

| App | Method |
|-----|--------|
| LibreOffice | apt |
| Zoom | `.deb`, else Flatpak, else snap |
| KeePassXC, Redshift, Flameshot | apt |
| balenaEtcher | apt (`.deb` from GitHub releases) |

### Development (`install/dev/`)

| Tool | Method |
|------|--------|
| Node.js | apt (NodeSource) |
| nvm | upstream install script |
| Python 3, pip, venv, dev headers | apt |
| Mason LSP runtimes (Go, Ruby, PHP, Java, Lua, Julia, C toolchain) | apt |
| Rust / cargo | rustup |
| Solargraph (Ruby gem for `solargraph` LSP) | gem (`--user-install`) |
| Vue CLI | npm global |
| Docker CE + Compose | apt (Docker vendor repo) |
| Neovim | apt (PPA) + Python extras |
| gh, shellcheck | apt (`dev-tools.packages`) |
| **Bruno** (API client) | apt ([debian.usebruno.com](http://debian.usebruno.com/)), else Flatpak |
| Semgrep | pip (`--user`) |
| Cursor Agent CLI | [cursor.com/install](https://cursor.com/install) |

### Security (`install/security/`)

| Tool | Method |
|------|--------|
| UFW, OpenVPN, nmap, exiftool | apt (`security.packages`) |
| ufw-docker | [chaifeng/ufw-docker](https://github.com/chaifeng/ufw-docker) → `/usr/local/bin` |
| Proton VPN | apt (vendor `.deb` + packages) |
| Proton Pass (desktop) | vendor `.deb` |
| pass-cli | GitHub release binary |
| Signal Desktop | apt (vendor repo) |
| OWASP ZAP | Flatpak, else snap (`--classic`) |
| PayloadsAllTheThings, SecLists | git clone into `~/Hacking` |

### Shell (`install/shell/`)

| Tool | Method |
|------|--------|
| zsh, tmux, powerline | apt |
| zsh-autosuggestions, zsh-syntax-highlighting | apt |
| Font Awesome, Fira Code, Powerline fonts | apt |
| Meslo Nerd Font | GitHub release → `/usr/share/fonts` |
| Oh My Posh | [ohmyposh.dev](https://ohmyposh.dev) → `~/.local/bin` |
| Ghostty | [ghostty-ubuntu](https://github.com/mkasberg/ghostty-ubuntu) install script |

### Preflight & post-install

- apt update/upgrade, essentials (git, curl, universe enabled)
- timezone (Los Angeles)
- Docker service enabled; UFW rules applied in config (LocalSend, Docker DNS, ufw-docker)

## Explicitly not installed

These are **not** provisioned by this repo (remove from old notes or other dotfiles if you still expect them):

| Removed / never included | Notes |
|--------------------------|--------|
| **Postman** | Replaced by **Bruno** |
| **Sourcegraph CLI (`sg`)** | Removed; use Bruno or other tooling |
| **Spotify** | Not provisioned; install manually if needed |
| **Standard Notes** | Flatpak install unreliable in CI; install manually if needed |
| GNOME apps via random snaps | snap only when listed above as fallback |
| Full IDE bundles (VS Code, JetBrains, etc.) | Dotfiles may reference extensions; install editors separately |
| 1Password, Bitwarden, etc. | Use Proton Pass / KeePassXC paths above |

## Configuration (`src/scripts/config/`)

Symlinks and settings from `src/dotfiles` (submodule): Zsh, tmux, Neovim, btop,
fastfetch, Kitty/Alacritty/Ghostty, Git, VS Code `settings.json`, GNOME
gsettings (skipped in CI without a GNOME session), UFW defaults and rules (LocalSend,
Docker DNS, ufw-docker), home directory
layout.

See [AGENTS.md](AGENTS.md) for contributor conventions, ShellCheck, and CI details.
