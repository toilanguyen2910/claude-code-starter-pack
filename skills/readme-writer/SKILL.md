---
name: readme-writer
description: Generates or updates a project README from the actual codebase structure, package manifest, and entry points. Use when the user asks to write, generate, or update a README.
allowed-tools: Read Glob Grep
---

# README writer

## Gather context first

Before writing anything, inspect the project instead of guessing:

1. Read the package manifest if present (`package.json`, `pyproject.toml`,
   `Cargo.toml`, `go.mod`, `*.csproj`, `project.godot`, etc.) for the name,
   description, and dependencies.
2. Glob the top-level structure to understand the project type (web app,
   CLI, library, game, script collection).
3. Look for an existing entry point (`main.*`, `index.*`, `app.*`) to
   understand how the project actually runs.
4. If a README already exists, read it fully — preserve any sections with
   information you can't infer from the code (like deployment notes or
   screenshots) instead of deleting them.

## Structure to produce

1. **Title + one-line description** — what it does, in plain language.
2. **Features** — 3-6 bullets, only things actually implemented, not a
   roadmap.
3. **Installation** — the exact commands, taken from the manifest/lockfile,
   not a generic placeholder.
4. **Usage** — a minimal working example. If it's a CLI, show the actual
   command and flags. If it's a library, show a short code snippet.
5. **Project structure** — only if the layout isn't a standard framework
   default and a reader would benefit from a map.
6. **Configuration** — environment variables or config files, if any exist.
7. **License** — pull from an existing LICENSE file if present; otherwise
   ask the user rather than assuming MIT.

## Rules

- Never invent features, badges, or stats (star counts, build status) that
  aren't verifiable from the repo.
- Don't add a "Contributing" or "Roadmap" section unless the user asks —
  most starter READMEs don't need one on day one.
- Keep the tone plain and direct. Skip marketing language like "blazing
  fast" or "seamless" unless it's demonstrably true and the user wants that
  tone.
- Write it as a `.md` file at the project root, not inline in chat, unless
  the user is only asking for a section to paste in themselves.
