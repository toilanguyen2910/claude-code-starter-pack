# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2025-07-01

### Added

- **4 Claude Code skills**: `commit-helper`, `code-reviewer`, `readme-writer`, `bug-report`
- **`CLAUDE.md.template`**: Project instructions template for Claude Code sessions
- **`protect-files.sh` hook**: Blocks Claude from editing secrets, lockfiles, `.git/`, and private keys
  - Smart fallback: `jq → python3 → python → grep/cut` for environments without `jq`
- **`setup.sh`**: One-command installer with `--project`, `--dry-run`, `--force` flags
- **`settings.json.example`**: Pre-wired hook configuration for Claude Code
- **Windows compatibility**: Python alias detection, `mktemp` for temp files
- **Test suites**: Bash (`tests/run.sh`) and PowerShell (`tests/run_windows.ps1`)
- **Documentation**: Getting started guide, skill authoring guide, walkthrough example
- **GitHub templates**: Bug report, feature request, PR template
- **Community files**: SECURITY.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md
