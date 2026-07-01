# claude-code-starter-pack

A small, opinionated starting point for [Claude Code](https://code.claude.com):
a `CLAUDE.md` template, four ready-to-use skills, and two example hooks —
installed with one script, into either your personal config or a single
project.

Not a framework. No dependencies to install. Just files you can read in
five minutes, copy, and edit.

## Why

Most Claude Code setups start the same way: an empty `CLAUDE.md`, no skills,
no hooks, and a half hour of trial and error before things feel useful.
This pack skips that — a working baseline you customize instead of building
from a blank page.

## What's included

```
claude-code-starter-pack/
├── CLAUDE.md.template          # project-instructions template
├── skills/
│   ├── commit-helper/          # writes Conventional Commits messages from the real diff
│   ├── code-reviewer/          # reviews uncommitted changes against a fixed checklist
│   ├── readme-writer/          # generates a README from the actual codebase, not guesses
│   └── bug-report/             # turns a vague bug description into a structured report
├── .claude/
│   ├── settings.json.example   # wires up the two hooks below
│   └── hooks/
│       └── protect-files.sh    # blocks Claude from editing .env, lockfiles, .git/
├── setup.sh                    # installs the above — see Quickstart
├── docs/
│   ├── getting-started.md
│   └── writing-skills.md       # how to write your own skill using these as examples
└── examples/
    └── walkthrough.md          # a full session using all four skills
```

## Quickstart

```bash
git clone https://github.com/toilanguyen2910/claude-code-starter-pack.git
cd claude-code-starter-pack
./setup.sh --project      # installs into the current project's .claude/
```

Then:

```bash
claude
```

```
/skills
```

You should see all four skills listed. Full walkthrough, uninstall
instructions, and flag reference: [`docs/getting-started.md`](docs/getting-started.md).

Prefer skills available in *every* project instead of just one? Run
`./setup.sh` (no flag) to install to `~/.claude/skills` instead.

## Skills at a glance

| Skill | Trigger | What it does |
|---|---|---|
| `commit-helper` | `/commit-helper` (manual only) | Stages changes and writes a Conventional Commits message from the actual `git diff` — not a description you type yourself. |
| `code-reviewer` | automatic, or `/code-reviewer` | Reviews the uncommitted diff (or a named file) against a fixed checklist: correctness, error handling, security, resource leaks, naming, test coverage. |
| `readme-writer` | automatic, or `/readme-writer` | Reads your package manifest and source tree, then writes or updates `README.md` from what's actually there. |
| `bug-report` | `/bug-report <description>` | Converts a rough bug description into a structured report, then optionally investigates the likely cause in the codebase. |

Each `SKILL.md` is under 60 lines and meant to be read, not just installed —
see [`docs/writing-skills.md`](docs/writing-skills.md) to adapt one for
your own workflow.

## Hooks

Two examples, off by default until you copy
`.claude/settings.json.example` to `.claude/settings.json` (which
`setup.sh --project` does for you):

- **`protect-files.sh`** (`PreToolUse`) — blocks edits to `.env`, lockfiles,
  `.git/`, and private key files, with the reason sent back to Claude so it
  can route around the block instead of retrying blindly.
- **Idle notification** (`Notification`) — prints a line when Claude is
  done and waiting for input.

Details and how to extend them: [`.claude/hooks/README.md`](.claude/hooks/README.md).

## Requirements

- [Claude Code](https://code.claude.com/docs/en/setup) installed.
- `bash` (macOS/Linux native; Windows via Git Bash or WSL).
- `jq`, only for the hooks — install with `brew install jq` or
  `apt-get install jq` if you don't already have it.

## Testing this repo

Everything here is plain text (markdown + JSON + shell), so there's no
build step — but it's still verified before every change:

```bash
./tests/run.sh
```

Checks: YAML frontmatter parses in all four `SKILL.md` files,
`settings.json.example` is valid JSON with `jq` and `python3` matching
what Claude Code expects, `protect-files.sh` passes `shellcheck` and
correctly blocks/allows the right paths, and `setup.sh` runs clean
end-to-end in both modes inside a scratch directory. See
[`tests/README.md`](tests/README.md) for what each check does.

## Contributing

Issues and PRs welcome — especially new skills that follow the same "short,
grounded in real repo state, no invented output" style as the ones here.

## License

[MIT](LICENSE)
