# Ubuntu setup scripts

Provisioning for a personal Ubuntu desktop: install scripts under
`src/scripts/install/`, dotfiles and system config under `src/scripts/config/`,
orchestrated by `master.sh`.

```bash
cd src/scripts
bash master.sh          # install + config
# or
bash run-install.sh     # install only
bash run-config.sh      # config only
```

CI runs `master.sh` on `ubuntu-latest`, then `scripts/validate.sh` to confirm
expected binaries/packages and config outcomes (dotfiles paths, UFW, system policy).

## Package manager preference

Install scripts prefer, in order:

1. **apt** (official `.deb` / apt repositories)
2. **snap**
3. **Flatpak** (Flathub)
4. **AppImage** or upstream static/binary releases

Fallback scripts try each format in that order and stop once the app is available.

## Install layout

| Path | Role |
|------|------|
| `install/preflight/` | apt update, essentials (git, curl, universe), timezone |
| `install/packages/*.packages` | One apt package per line; installed by `packages/all.sh` |
| `install/griffo.sh`, `fastfetch.sh`, `btop.sh`, `flatpak.sh` | Repos, PPAs, or fallbacks only where apt lists are not enough |
| `install/apps/` | Vendor apt repos, `.deb`, then snap, Flatpak, or AppImage fallbacks |
| `install/dev/` | NodeSource, nvm, LSP language stacks, Docker, Neovim PPA, rustup, gems, pip/npm tools |
| `install/shell/` | Ghostty, Meslo font, Oh My Posh |
| `install/post-install/` | apt maintain, Docker service, completion banner |

### Package lists (`install/packages/`)

| File | Contents |
|------|----------|
| `base.packages` | CLI and security tools (bat, fzf, gh, jq, ripgrep, ufw, nmap, exiftool, …) |
| `shell.packages` | zsh, tmux, fonts, plugins |
| `media.packages` | vlc, ffmpeg, gstreamer |
| `desktop.packages` | GNOME Tweaks, shell extensions |
| `productivity.packages` | LibreOffice, KeePassXC, Redshift, Flameshot |
| `lsp.packages` | Mason LSP runtimes (Go, Ruby, PHP, Lua, …) |
| `lsp-optional.packages` | Julia (skipped when unavailable on apt) |
| `dev.packages` | Neovim, Python |
| `griffo.packages` | yazi, lazygit, lazydocker ([debian.griffo.io](https://debian.griffo.io/apt)) |
| `fastfetch.packages` | fastfetch (PPA) |

### Apps (`install/apps/`)

Brave, Signal, Proton VPN/Pass, Bruno, Zoom, Etcher, OWASP ZAP, ufw-docker,
Hacking git clones — each script handles its own repo or `.deb` when apt lists are
not enough.

### Development (`install/dev/`)

Node.js (NodeSource), nvm, Docker CE + Compose, rustup, Solargraph gem, Semgrep,
Vue CLI, Cursor Agent CLI.

### Preflight & post-install

- apt update/upgrade, essentials, universe, timezone (Los Angeles)
- Docker service enabled; UFW rules in `config/security/` (LocalSend, Docker DNS, ufw-docker)

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
Docker DNS, ufw-docker), home directory layout.

See [AGENTS.md](AGENTS.md) for contributor conventions, ShellCheck, and CI details.
