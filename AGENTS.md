# Agent instructions

Ubuntu provisioning scripts under `src/scripts/`: Omarchy-style per-app install/config
scripts, orchestrated by `master.sh`, `run-install.sh`, and `run-config.sh`. The
`src/dotfiles` submodule is maintained separately. **Never edit, commit, or bump
`src/dotfiles` from this repo** unless the user explicitly asks. Consume it read-only
via `src/dotfiles/setup.sh --link-xdg-config` (symlinks) and targeted file copies.

## Before you finish

**Do not consider shell or workflow work complete until ShellCheck passes the same way CI does.**

From the repository root:

```bash
chmod +x scripts/check-shellcheck.sh
./scripts/check-shellcheck.sh
```

That runs `shellcheck -x` on **changed** `*.sh` / `*.bash` / `*.zsh` files vs `origin/master`
(matching [quality-checks](https://github.com/garretpatten/quality-checks)). Uses
`.shellcheckrc` (`external-sources=true`, `source-path=SCRIPTDIR`).

To lint all setup scripts locally:

```bash
shellcheck -x src/scripts/**/*.sh
# or
find src/scripts -name '*.sh' -print0 | xargs -0 shellcheck -x
```

### ShellCheck conventions

- Leaf scripts under `install/` and `config/` should be plain commands; avoid
  `source utils.sh` and wrapper functions.
- Orchestrators (`master.sh`, `*/all.sh`) source `lib/env.sh`, `lib/run.sh`, and
  `# shellcheck source=...` for any other `lib/*.sh` they use.
- Do not use `A && B || C` for conditional execution (CI reports **SC2015**). Use
  `if` / `then` / `fi` instead.
- `|| true` on a single command is fine for best-effort provisioning.

### Other CI linters

`.github/workflows/quality-checks.yaml` also runs Prettier, markdownlint, and yamllint on
pull requests. Run `npm ci` and the relevant tools when you touch those file types.

### Test workflow

`.github/workflows/test-runner.yaml` runs `src/scripts/master.sh` on `ubuntu-latest`, then
`scripts/validate.sh` (install binaries/packages and config paths/settings).
GNOME gsettings scripts no-op without an active GNOME session.

## Layout

| Path | Role |
|------|------|
| `src/scripts/lib/env.sh` | `PROJECT_ROOT`, `TEMP_DIR` |
| `src/scripts/lib/run.sh` | `run_script` helper |
| `src/scripts/lib/gnome-session.sh` | Skip GNOME config when not on GNOME |
| `src/scripts/lib/zsh-login.sh` | `.zshrc` pass-cli guard for provisioning |
| `src/scripts/install/packages/*.packages` | Apt package lists (one per line) |
| `src/scripts/lib/apt-packages.sh` | `install_apt_packages_from_file` helper |
| `src/scripts/install/` | `packages/`, `apps/`, `dev/`, `shell/`, `post-install/` |
| `src/scripts/config/<category>/` | Dotfiles/GNOME/system config + `all.sh` |

## Commits

Only commit when the user asks. Do not commit secrets.
