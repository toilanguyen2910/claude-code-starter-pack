# Tests

## Running

```bash
./tests/run.sh
```

## What each check does

| Test | What it validates |
|---|---|
| 1. SKILL.md frontmatter | YAML frontmatter parses, has `name` and `description`, `name` matches directory |
| 2. JSON files | `.claude/settings.json.example` is valid JSON |
| 3. shellcheck | `setup.sh` and `.claude/hooks/protect-files.sh` pass shellcheck at warning level |
| 4. protect-files.sh behavior | Hook correctly allows normal files and blocks `.env`, lockfiles, `.git/`, and key files |
| 5. setup.sh dry run | `--dry-run` flag doesn't create any files |
| 6. setup.sh personal mode | Installs 4 skills to `~/.claude/skills`, creates `CLAUDE.md`, is idempotent |
| 7. setup.sh project mode | Installs 4 skills to `.claude/skills`, copies settings and hooks |
| 8. README consistency | README mentions all 4 skills, and all 4 skill directories exist |

## Requirements

- `bash`
- `python3` with `pyyaml`
- `jq`
- `shellcheck`
