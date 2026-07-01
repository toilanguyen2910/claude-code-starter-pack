# Getting started

## Prerequisites

- [Claude Code](https://code.claude.com/docs/en/setup) installed.
- `bash` (macOS/Linux native; Windows via Git Bash or WSL).
- `jq` (optional, only for hooks) — install with `brew install jq` or
  `apt-get install jq`.

## Installation

### Personal mode (all projects)

```bash
git clone https://github.com/toilanguyen2910/claude-code-starter-pack.git
cd claude-code-starter-pack
./setup.sh
```

This installs skills to `~/.claude/skills` so they're available in every
project, and copies `CLAUDE.md.template` to `./CLAUDE.md` in the current
directory.

### Project mode (single project)

```bash
cd /path/to/your-project
/path/to/claude-code-starter-pack/setup.sh --project
```

This installs skills, hooks, and settings into `./.claude/` in the current
project directory.

## Flags

| Flag | Description |
|---|---|
| `--project` | Install into `./.claude/` (project-scoped) instead of `~/.claude/` |
| `--dry-run` | Preview what would happen without making changes |
| `--force` | Overwrite existing files instead of skipping them |
| `--help` | Show usage help |

## Verify installation

```bash
claude
```

Then inside the session:

```
/skills
```

You should see all four skills listed:
- `commit-helper`
- `code-reviewer`
- `readme-writer`
- `bug-report`

## Uninstall

### Personal mode

```bash
rm -rf ~/.claude/skills/{commit-helper,code-reviewer,readme-writer,bug-report}
rm ./CLAUDE.md   # if you haven't customized it
```

### Project mode

```bash
rm -rf .claude/skills/{commit-helper,code-reviewer,readme-writer,bug-report}
rm .claude/hooks/protect-files.sh
# Optionally remove .claude/settings.json if you don't have other settings
```
