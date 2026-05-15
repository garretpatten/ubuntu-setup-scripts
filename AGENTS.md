# Agent guide — ubuntu-setup-scripts

Bash automation for Ubuntu (20.04+) development machines: modular install scripts,
shared helpers, and a `src/dotfiles` git submodule. Changes should stay
**idempotent**, **safe to re-run**, and compatible with **headless CI** (no GNOME
session).

## Repository layout

| Path                   | Purpose                                                                                                                    |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `src/scripts/`         | Install scripts; `master.sh` runs them in order                                                                            |
| `src/scripts/utils.sh` | Shared helpers, paths, logging, apt/gsettings utilities                                                                    |
| `src/dotfiles/`        | **Git submodule** ([garretpatten/dotfiles](https://github.com/garretpatten/dotfiles)) — `config/`, `home/`, Neovim, shells |
| `src/assets/`          | Static assets (e.g. post-install art)                                                                                      |
| `.github/workflows/`   | CI: full `master.sh` on push/PR; quality checks on PR                                                                      |

**Orchestration** (`master.sh`): `pre-install.sh` → `organizeHome.sh` →
`system-config.sh` → `cli.sh` → `dev.sh` → `media.sh` → `productivity.sh` →
`security.sh` → `shell.sh` → `post-install.sh`.

## Script conventions

Every script under `src/scripts/` should:

1. Start with `#!/bin/bash`, resolve `SCRIPT_DIR`, and `source "$SCRIPT_DIR/utils.sh"`.
2. Use helpers from `utils.sh` instead of ad-hoc `apt`, `curl`, or `cp` when possible:
   `install_apt_packages`, `update_apt_cache`, `download_file_safe`, `copy_file_safe`,
   `clone_repository_safe`, `ensure_directory`, `log_error`.
3. Append failures to `"$ERROR_LOG_FILE"` (`setup_errors.log` at repo root) via `2>>"$ERROR_LOG_FILE"` or `log_error`.
4. Prefer **non-fatal** steps in CI: `master.sh` uses `|| log_error` per stage; individual commands often use `|| true` where a partial failure is acceptable.
5. Remain **idempotent**: skip work if already done (existing dirs, keyrings, clones, dotfile targets).

Paths:

- `PROJECT_ROOT` — repository root (two levels above `src/scripts/`).
- Dotfiles live at `$PROJECT_ROOT/src/dotfiles`; scripts copy into `~/.config` and `$HOME` only when targets are missing (see `shell.sh`, `dev.sh`).

**GNOME / desktop**: Use `gsettings_ok` before `gsettings_set`. Headless runners have no D-Bus session; `gsettings` steps must no-op safely. Do not assume a logged-in desktop in CI.

**Dotfiles submodule**: After clone, run `git submodule update --init --recursive src/dotfiles/`. Config edits that belong in personal dotfiles should go in the **dotfiles repo**, not duplicated in setup scripts unless the script is the single source of install-time behavior.

## Product and safety constraints

- **Night Light** (`system-config.sh`) vs **Redshift** (`productivity.sh`): do not enable both; document conflicts in README if you change either.
- **Security**: Prefer verified downloads (GPG keyrings, `download_file_safe`), least-privilege directory permissions, and UFW defaults from `security.sh` / `post-install.sh`.
- **User impact**: Many changes need logout/relogin (docker group, default shell, GNOME). Mention that in README when adding steps that require it.
- Do not commit secrets, API keys, or machine-specific paths in scripts or dotfiles.

## Testing and CI

- **Test Runner** (`.github/workflows/test-runner.yaml`): `chmod +x src/scripts/*.sh`, run `src/scripts/master.sh` on `ubuntu-latest` (errors tolerated with `|| true`), then fail if `setup_errors.log` has non-whitelisted lines after filtering known apt/docker/chsh noise.
- **Quality checks** (PR): Prettier, ShellCheck, markdownlint, and **yamllint** (yamllint is CI-only; agents do not need to run it locally).

When adding install steps, consider whether they produce benign noise in CI logs; extend the test-runner filter only for known false positives, not to hide real failures.

## Making changes

| Task                            | Where to edit                                                                                |
| ------------------------------- | -------------------------------------------------------------------------------------------- |
| New packages or tools           | Appropriate topical script (`dev.sh`, `security.sh`, etc.) or new script + `master.sh` entry |
| Shared install/download logic   | `utils.sh`                                                                                   |
| Desktop / APT / system defaults | `system-config.sh`, `pre-install.sh`, `post-install.sh`                                      |
| Shell, terminal, dotfile deploy | `shell.sh`; dotfile content in submodule `src/dotfiles/`                                     |
| User-facing behavior docs       | `README.md`                                                                                  |

Keep diffs focused: one concern per change. Match existing style (lowercase `log_error` messages, `readonly` globals in `utils.sh`, `shellcheck disable=SC1091` for sourced files).

## Commits and PRs

- Do not create commits or open PRs unless the user asks.
- Follow existing commit message tone (short, imperative summary).
- PRs should note manual test plan on real Ubuntu desktop when touching `gsettings`, dock, or display-related code.

## Verify before you finish

Before wrapping up edits, run **Prettier**, **ShellCheck**, and **markdownlint** on Markdown (`*.md` via [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)—not YAML). PR workflows also run **yamllint** on YAML workflow files in CI; you do **not** need to run `yamllint` locally. Install ShellCheck via your OS package manager if it is missing. From the **repository root**:

```bash
npm install

npx prettier --check .
shellcheck src/scripts/*.sh
npx markdownlint-cli2 "**/*.md" "#node_modules" "#src/dotfiles/node_modules"
```

All three commands must exit 0. Use `npx prettier --write .` only to apply formatting, then re-run `--check`. If you changed files under `src/dotfiles/`, run the same tools there as well (that submodule has its own `package.json` and CI).

## License

MIT — see [LICENSE](./LICENSE).
