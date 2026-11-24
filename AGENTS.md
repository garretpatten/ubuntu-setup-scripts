# Agent instructions

Ubuntu provisioning scripts under `src/scripts/`: Omarchy-style per-app install/config
scripts, orchestrated by `master.sh`, `run-install.sh`, and `run-config.sh`.
`run-install.sh` accepts `cli` (CLI-only) or `all` (CLI + desktop/native); npm
shortcuts are `npm run install:cli`, `npm run install:all`, `npm run config`, and
`npm run all`. The `src/dotfiles` submodule is maintained separately. **Never edit,
commit, or bump `src/dotfiles` from this repo** unless the user explicitly asks.
Consume it read-only via `link_dotfiles_xdg_config_dirs` in `config/dotfiles.sh`
(symlinks each `src/dotfiles/config/<app>/` under `~/.config/`) and targeted file copies.
`run-config.sh` and `master.sh` initialize/update submodules before running config.

## Repository standards

[garretpatten/github-standards](https://github.com/garretpatten/github-standards) is the
**canonical source of truth** for how every `garretpatten` repository must be structured
and maintained: license, security policy, contributing, community files, README
branding, CODEOWNERS, branch protection, pull requests, signed commits, Dependabot,
dependency hygiene, secret hygiene, workflow permissions, action pinning, repository
metadata, CI and quality, and exceptions.

- **Before starting any task**, read the current standards from the source of truth
  rather than from memory or a cached copy — they change over time. The standards index
  is at <https://github.com/garretpatten/github-standards#standards-files>; fetch raw
  files from
  `https://raw.githubusercontent.com/garretpatten/github-standards/master/<standard>.md`
  (via web fetch, `curl`, or `gh api`) and read every standard relevant to the task.
- **While working**, apply the standards to every change: workflows, dependency files,
  community files, repository metadata, and commit practices must conform to the
  standards as they exist at the time of the change.
- **When you detect drift** — this repository lagging behind a standard that changed —
  bring the repository back in line as part of normal work and call it out in your
  summary. If an update would be large or ambiguous, propose it instead of applying it
  silently.
- **Before finishing**, confirm the work satisfies the
  [verification](https://github.com/garretpatten/github-standards/blob/master/verification.md)
  standard and that local checks pass.
- For a full compliance review, use the `github-audit` skill, which audits a repository
  against these standards and reports numbered findings.

## Dotfiles submodule

`src/dotfiles/` is a **Git submodule** pinned to a commit of
[garretpatten/dotfiles](https://github.com/garretpatten/dotfiles).
Never edit files inside `src/dotfiles/` directly in this repository.

If a dotfiles change is needed:

1. Make the change in the `dotfiles` repository and push it.
2. In this repository, update the submodule:
   `cd src/dotfiles && git pull origin master && cd ../..`
3. Commit the submodule pointer change:
   `git add src/dotfiles && git commit -m "Bump dotfiles submodule"`

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
pull requests. Prettier and markdownlint are installed via `npm ci`; yamllint is a Python
tool. Run the relevant tools when you touch those file types:

```bash
npm ci
npx prettier --check .
npx markdownlint --ignore node_modules '**/*.md'
yamllint .
```

### Unit tests

`tests/` holds [bats-core](https://github.com/bats-core/bats-core) unit tests for
`src/scripts/lib/`, `scripts/check-shellcheck.sh`, and
`src/scripts/install/dev/google-mcp-server.sh`. Install bats locally with
`./scripts/install-bats.sh`, then run `npm run test:shell` or
`bats --recursive tests/`. Tests sandbox `HOME` and stub apt, sudo, curl, and
npm; they must not use the network or real credentials.

`scripts/check-shellcheck.sh` ShellChecks changed `*.sh` / `*.bash` / `*.zsh` /
`*.bats` files vs `origin/master`. The `unit-tests` job also ShellChecks every
file under `tests/` (including extensionless stubs, excluding fixtures).

### Test workflow

`.github/workflows/test-runner.yaml` runs five jobs on `ubuntu-latest`:

- `unit-tests`: ShellCheck on `tests/`, then `bats --recursive tests/`
- `test-cli`: `run-install.sh cli` → `scripts/validate-installs-cli.sh`
- `test-config`: `run-config.sh` → `scripts/validate-config-only.sh`
- `test-full`: `run-install.sh all` → `scripts/validate-installs.sh`
- `test-master`: `master.sh` → `scripts/validate.sh` (full installs + config)

GNOME gsettings scripts no-op without an active GNOME session. Leaf installers
under `src/scripts/install/` and `src/scripts/config/` (except
`install/dev/google-mcp-server.sh`) are covered by the container jobs, not by
bats.

## Layout

| Path                                                        | Role                                                    |
| ----------------------------------------------------------- | ------------------------------------------------------- |
| `src/scripts/lib/env.sh`                                    | `PROJECT_ROOT`, `TEMP_DIR`                              |
| `src/scripts/lib/run.sh`                                    | `run_script` helper (forwards extra args)               |
| `src/scripts/lib/gnome-session.sh`                          | Skip GNOME config when not on GNOME                     |
| `src/scripts/lib/zsh-login.sh`                              | `.zshrc` pass-cli guard for provisioning                |
| `src/scripts/lib/git-submodules.sh`                         | Initialize/update submodules before config              |
| `src/scripts/install/all.sh`                                | Full install orchestrator (`--cli` for CLI-only)        |
| `src/scripts/install/cli.sh`                                | Wrapper that runs `install/all.sh --cli`                |
| `src/scripts/install/packages/*.packages`                   | Apt package lists (one per line)                        |
| `src/scripts/install/packages/third-party-cli.packages`     | Docker/NodeSource packages for CLI install              |
| `src/scripts/install/packages/third-party-desktop.packages` | Brave/Bruno/Signal packages for full install            |
| `src/scripts/install/apps/pass-cli.sh`                      | Proton Pass CLI binary install                          |
| `src/scripts/lib/apt-packages.sh`                           | `install_apt_packages_from_file` helper                 |
| `src/scripts/install/`                                      | `packages/`, `apps/`, `dev/`, `shell/`, `post-install/` |
| `src/scripts/config/<category>/`                            | Dotfiles/GNOME/system config + `all.sh`                 |
| `scripts/lib/validate-installs-sections.sh`                 | Shared install validation sections                      |
| `scripts/lib/validate-config-sections.sh`                   | Shared config validation sections                       |
| `scripts/validate-installs-cli.sh`                          | Validate CLI-only install outcomes                      |
| `scripts/validate-installs.sh`                              | Validate full install outcomes                          |
| `scripts/validate-config-only.sh`                           | Validate config-only outcomes                           |
| `scripts/validate-config.sh`                                | Validate config after full install/master               |
| `scripts/install-bats.sh`                                   | Install bats-core 1.14.0 and helper libs into `.tools/` |
| `scripts/check-shellcheck.sh`                               | ShellCheck changed `*.sh`/`*.bash`/`*.zsh`/`*.bats`     |
| `tests/`                                                    | bats unit tests (see Unit tests above)                  |

## Commits

Only commit when the user asks. Do not commit secrets.

## GitHub Actions

Whenever a GitHub workflow is added, all GitHub Action pins in that workflow
should be updated to point to the full-length commit SHA of the most recent
release.
