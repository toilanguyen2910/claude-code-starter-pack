# Writing your own skills

This guide explains how to create a Claude Code skill using the four skills
in this pack as examples.

## What is a skill?

A skill is a folder containing a `SKILL.md` file. When Claude Code loads it,
the frontmatter tells Claude *when* to activate the skill, and the body tells
it *what to do*.

## File structure

```
skills/
└── your-skill-name/
    └── SKILL.md
```

The directory name should match the `name` field in frontmatter.

## SKILL.md anatomy

```yaml
---
name: your-skill-name
description: One sentence explaining what this skill does and when to use it.
---
```

### Required frontmatter fields

| Field | Purpose |
|---|---|
| `name` | Identifier for the skill. Must match the directory name. |
| `description` | Tells Claude when to activate this skill. Write it as a trigger condition. |

### Optional frontmatter fields

| Field | Purpose |
|---|---|
| `allowed-tools` | Restricts which tools the skill can use. |
| `disable-model-invocation` | If `true`, prevents the skill from calling other models. |
| `argument-hint` | Shows users what arguments the skill accepts. |

## Writing the body

The body is plain markdown — Claude reads it as instructions. Keep these
principles in mind:

### 1. Ground it in real data

Don't describe hypothetical outputs. Use inline shell commands to read
the actual project state:

```markdown
- Status: !`git status --short`
- Current branch: !`git branch --show-current`
```

### 2. Be prescriptive, not descriptive

Bad: "You might want to check for errors."
Good: "Check each function for uncaught exceptions. If found, report the
file and line number."

### 3. Include a concrete example

Show what the output should look like for a real scenario. This anchors
Claude's behavior far better than abstract rules.

### 4. Set boundaries

Tell the skill what NOT to do. Examples from the pack:

- commit-helper: "Never use `git commit --amend` unless explicitly asked."
- bug-report: "Don't open a fix without being asked."
- readme-writer: "Never invent features or badges."

### 5. Keep it short

Each `SKILL.md` in this pack is under 60 lines. If you're writing more than
that, consider splitting into multiple skills or moving reference material
into a separate file.

## Testing your skill

1. Install it: copy the folder to `~/.claude/skills/` or `.claude/skills/`.
2. Start a Claude Code session.
3. Run `/skills` to verify it appears.
4. Trigger it with the appropriate command or context.
5. Check that the output matches your expectations.

## Examples from this pack

| Skill | Key technique |
|---|---|
| `commit-helper` | Uses `!git diff` to ground the commit message in real changes |
| `code-reviewer` | Fixed checklist ensures consistent, non-generic reviews |
| `readme-writer` | Reads manifest files before writing, never invents features |
| `bug-report` | Structured template with explicit "ask, don't invent" rule |
