# Contributing

Participants are expected to follow the [Code of Conduct](./CODE_OF_CONDUCT.md).

## Issues

Security vulnerabilities are **not** tracked in public issues until addressed; see **[SECURITY.md](./SECURITY.md)**.

Use [GitHub Issues](https://github.com/garretpatten/ubuntu-setup-scripts/issues) with the **Bug report** or **Feature request** form. Include Ubuntu version (`lsb_release -a`), desktop vs headless context, commands run, and relevant lines from **`setup_errors.log`** (redact private paths).

## Pull requests

- Branch from **`master`**, focused scope per PR.
- When scripts change, keep installs idempotent (skip work if keys, dirs, or targets already satisfy the goal).
- **Headless-safe**: **`gsettings`** only behind **`gsettings_ok`**; do not require a GNOME session in CI paths.
- **Dotfiles submodule**: substantive config belongs in **`src/dotfiles`** upstream unless the provisioning script owns one-off machine behavior — note submodule bumps explicitly when you change **`src/dotfiles`**.

### Checks (from repo root)

```bash
npm install

npx prettier --check .
shellcheck src/scripts/utils.sh \
  src/scripts/master.sh \
  src/scripts/run-install.sh \
  src/scripts/run-config.sh \
  src/scripts/install/*.sh \
  src/scripts/config/*.sh
npx markdownlint-cli2 "**/*.md" "#node_modules" "#src/dotfiles/node_modules"
```

YAML workflow edits are **`yamllint`**-scoped in CI; match **`.yamllint`** (80-character lines).

Documentation-only changes still need **`prettier`** and **`markdownlint`** on touched Markdown files.
