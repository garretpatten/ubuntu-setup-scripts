# Ubuntu setup scripts

Provisioning for a personal Ubuntu desktop: install scripts under
`src/scripts/install/`, dotfiles and system config under `src/scripts/config/`,
orchestrated by `master.sh`.

```bash
npm run all             # install + config
npm run install:cli     # CLI-only install
npm run install:all     # full install (CLI + desktop/native)
npm run config          # config only (ensures submodules are up to date)
```

Direct bash equivalents (from `src/scripts/`):

```bash
bash master.sh          # install + config
bash run-install.sh cli # CLI-only install
bash run-install.sh all # full install (default)
bash run-config.sh      # config only
```

CI runs four jobs on `ubuntu-latest`:

- `test-cli`: `run-install.sh cli` → `validate-installs-cli.sh`
- `test-config`: `run-config.sh` → `validate-config-only.sh`
- `test-full`: `run-install.sh all` → `validate-installs.sh`
- `test-master`: `master.sh` → `validate.sh` (full installs + config)

Each validation script confirms the expected binaries/packages and config outcomes
for that run mode.

## Package manager preference

Each app uses one install path:

1. **apt** when the package or vendor repo is available
2. **snap** when apt does not provide it (Zoom, OWASP ZAP)
3. **Upstream `.deb` or binary** only when neither apt nor snap applies (Etcher, Proton Pass, pass-cli)

## Install layout

| Path                          | Role                                                                                  |
| ----------------------------- | ------------------------------------------------------------------------------------- |
| `install/preflight/`          | apt update, essentials (git, curl, universe), timezone                                |
| `install/all.sh`              | Full install orchestrator (`--cli` for CLI-only mode)                                 |
| `install/cli.sh`              | Thin wrapper that runs `install/all.sh --cli`                                         |
| `install/packages/*.packages` | One apt package per line; installed by `install/all.sh`                               |
| `install/repos/manifest`      | Third-party apt repo definitions consumed by `install/repos/setup.sh`                 |
| `install/snaps.txt`           | Snap packages installed by `install/apps/snaps.sh`                                    |
| `install/apps/`               | `.deb` downloads and app-specific installers                                          |
| `install/dev/`                | NodeSource, nvm, LSP language stacks, Docker, Neovim PPA, rustup, gems, pip/npm tools |
| `install/shell/`              | Ghostty, Meslo font, Oh My Posh                                                       |
| `install/post-install/`       | apt maintain, Docker service, tldr cache, completion banner                           |

### Validation scripts (`scripts/`)

| Script                     | Use with                                   |
| -------------------------- | ------------------------------------------ |
| `validate-installs-cli.sh` | After `run-install.sh cli`                 |
| `validate-installs.sh`     | After `run-install.sh all` or `master.sh`  |
| `validate-config-only.sh`  | After `run-config.sh`                      |
| `validate-config.sh`       | After `master.sh` or full install + config |
| `validate.sh`              | After `master.sh` (installs + config)      |

### Package lists (`install/packages/`)

| File                           | Contents                                                                                  |
| ------------------------------ | ----------------------------------------------------------------------------------------- |
| `base.packages`                | CLI and security tools (bat, fzf, gh, jq, ripgrep, tldr/tealdeer, ufw, nmap, exiftool, …) |
| `shell.packages`               | zsh, tmux, fonts, plugins                                                                 |
| `media.packages`               | vlc, ffmpeg, gstreamer                                                                    |
| `desktop.packages`             | GNOME Tweaks, shell extensions                                                            |
| `productivity.packages`        | LibreOffice, KeePassXC, Redshift, Flameshot                                               |
| `lsp.packages`                 | Mason LSP runtimes (Go, Ruby, PHP, Lua, …)                                                |
| `lsp-optional.packages`        | Julia (skipped when unavailable on apt)                                                   |
| `dev.packages`                 | Neovim, Python                                                                            |
| `griffo.packages`              | yazi, lazygit, lazydocker ([debian.griffo.io](https://debian.griffo.io/apt))              |
| `fastfetch.packages`           | fastfetch (PPA)                                                                           |
| `third-party-cli.packages`     | Docker CE/Compose, Node.js (NodeSource)                                                   |
| `third-party-desktop.packages` | Brave, Bruno, Signal Desktop, appindicator libs                                           |

### Apps (`install/apps/`)

Brave, Chrome, Signal, Proton VPN/Pass, Bruno, Zoom, Etcher, OWASP ZAP, ufw-docker,
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

| Removed / never included                    | Notes                                                         |
| ------------------------------------------- | ------------------------------------------------------------- |
| **Postman**                                 | Replaced by **Bruno**                                         |
| **Sourcegraph CLI (`sg`)**                  | Removed; use Bruno or other tooling                           |
| **Spotify**                                 | Not provisioned; install manually if needed                   |
| GNOME apps via random snaps                 | Not provisioned                                               |
| Full IDE bundles (VS Code, JetBrains, etc.) | Dotfiles may reference extensions; install editors separately |
| 1Password, Bitwarden, etc.                  | Use Proton Pass / KeePassXC paths above                       |

## Configuration (`src/scripts/config/`)

Symlinks and settings from `src/dotfiles` (submodule, read-only): `config/dotfiles.sh`
symlinks each `config/<app>/` tree under `~/.config/` (including `zsh/` for OS-specific
shell snippets); copies for shell home files and VS Code settings. Covers Neovim, btop,
fastfetch, Kitty/Alacritty/Ghostty, Git, GNOME gsettings (skipped in CI without a GNOME
session), UFW defaults and rules (LocalSend, Docker DNS, ufw-docker), home directory layout.

See [AGENTS.md](AGENTS.md) for contributor conventions, ShellCheck, and CI details.
