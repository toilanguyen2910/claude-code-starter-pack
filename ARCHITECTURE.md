# Architecture

## Overview

claude-code-starter-pack is a collection of plain-text files (Markdown, JSON,
and shell scripts) that configure Claude Code. There is no build step, no
runtime, and no framework — just files that Claude Code reads.

## Component Map

```
┌─────────────────────────────────────────────────────────┐
│                    User's Project                       │
│                                                         │
│  CLAUDE.md  ◄── copied from CLAUDE.md.template          │
│                                                         │
│  .claude/                                               │
│  ├── settings.json  ◄── hooks config                    │
│  ├── hooks/                                             │
│  │   └── protect-files.sh  ◄── PreToolUse guard         │
│  └── skills/                                            │
│      ├── commit-helper/SKILL.md                         │
│      ├── code-reviewer/SKILL.md                         │
│      ├── readme-writer/SKILL.md                         │
│      └── bug-report/SKILL.md                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
         ▲                            ▲
         │  setup.sh --project        │  setup.sh (personal)
         │  installs here             │  installs to ~/.claude/
         │                            │
┌────────┴────────────────────────────┴───────────────────┐
│              claude-code-starter-pack/                   │
│                                                         │
│  skills/          ← source skill definitions            │
│  .claude/         ← source hooks + settings             │
│  setup.sh         ← installer                           │
│  tests/           ← validation suite                    │
│  docs/            ← documentation                       │
│  examples/        ← usage walkthrough                   │
└─────────────────────────────────────────────────────────┘
```

## Data Flow

### Skills

```
User prompt → Claude Code matches skill description → SKILL.md loaded →
Claude follows instructions → output to user
```

Skills are activated by matching the `description` field in frontmatter
against the user's intent. They are loaded on-demand (not on every turn),
so they don't consume tokens when unused.

### Hooks

```
Claude calls Edit/Write tool → PreToolUse hook fires →
protect-files.sh reads JSON stdin → checks file path against patterns →
exit 0 (allow) or exit 2 (block with feedback)
```

The hook receives tool input as JSON on stdin. It extracts `file_path`
using `jq`, `python`, or `grep/cut` (fallback chain for portability).

### Setup

```
setup.sh → reads --project or personal mode →
copies skills/ to target → copies hooks + settings (project mode) →
copies CLAUDE.md.template → done
```

The installer is idempotent: re-running skips existing files unless
`--force` is specified.

## Design Decisions

1. **No dependencies**: Everything is bash + standard Unix tools. Python
   and jq are optional (used when available, graceful fallback otherwise).

2. **Short skills**: Each SKILL.md is under 60 lines. Long instructions
   get ignored or hallucinated over — short and prescriptive works better.

3. **Grounded in real state**: Skills use `!`-prefixed shell commands to
   read actual project state (git diff, git status) rather than asking
   Claude to guess.

4. **Separate test suites**: `tests/run.sh` for bash environments,
   `tests/run_windows.ps1` for native Windows — both validate the same
   properties.
