# Security Policy

## Supported versions

| Version / branch | Supported          |
| ---------------- | ------------------ |
| `master` (latest) | :white_check_mark: |
| older snapshots  | :x:                |

Security fixes apply to the default branch. There are no tagged releases; use the latest `master` when running these scripts on a machine.

## Reporting a vulnerability

Report a vulnerability directly to the maintainer at [garret.patten@proton.me](mailto:garret.patten@proton.me). Do not open public GitHub issues for security-sensitive reports.

If a vulnerability is accepted, updates will be given on meaningful status changes. If a report is declined, brief reasoning will be provided.

## Scope

This repository contains personal Ubuntu desktop provisioning scripts. It is not a deployed service and has no user accounts. Still report issues that could harm someone running these scripts—malicious or unsafe shell patterns, compromised download URLs or install paths, privilege-escalation bugs, secrets committed to the repo, or similar.

In scope:

- Scripts under `src/scripts/` (install, config, orchestrators, and shared `lib/`)
- CI workflows and validation under `.github/` and `scripts/`
- Submodule pointer and integration with `src/dotfiles` (report dotfile content issues in [garretpatten/dotfiles](https://github.com/garretpatten/dotfiles))

Out of scope:

- Vulnerabilities in third-party packages installed by these scripts (report those to the upstream vendor)
- General hardening of a fully provisioned system beyond what this repo configures

Do not commit secrets, credentials, or sensitive personal data. Pull requests run automated security checks (Semgrep, Trufflehog) via the [security-checks](https://github.com/garretpatten/security-checks) workflow.
