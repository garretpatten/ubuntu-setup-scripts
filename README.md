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

| Tool | Method |
|------|--------|
| bat, curl, eza, fd-find, git, htop, jq, ripgrep, vim, wget | apt (universe) |
| yazi, lazygit | apt ([debian.griffo.io](https://debian.griffo.io/apt)) |
| btop | apt (Ubuntu ≥ 22.04), else GitHub musl binary, else snap |
| fastfetch | apt (PPA) |
| flatpak + Flathub | apt + flatpak remotes |

### Media (`install/media/`)

| App | Method |
|-----|--------|
| Brave Browser | apt (vendor repo) |
| VLC | apt |
| ffmpeg, ubuntu-restricted-extras | apt |

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
| gh, shellcheck, git | apt |
| **Bruno** (API client) | apt ([debian.usebruno.com](http://debian.usebruno.com/)), else Flatpak |
| Semgrep | pip (`--user`) |
| Cursor Agent CLI | [cursor.com/install](https://cursor.com/install) |

### Security (`install/security/`)

| Tool | Method |
|------|--------|
| UFW, OpenVPN | apt |
| Proton VPN | apt (vendor `.deb` + packages) |
| Proton Pass (desktop) | vendor `.deb` |
| pass-cli | GitHub release binary |
| Signal Desktop | apt (vendor repo) |
| nmap, exiftool | apt |
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
- Docker service enabled; UFW enabled after rules config

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
gsettings (skipped in CI without a GNOME session), UFW rules, home directory
layout.

See [AGENTS.md](AGENTS.md) for contributor conventions, ShellCheck, and CI details.
