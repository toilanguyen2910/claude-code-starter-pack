---
name: commit-helper
description: Stages changes and writes a Conventional Commits message from the actual diff. Use when the user asks to commit, wants a commit message, or says "commit this".
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *) Bash(git diff *)
---

# Commit helper

## Current state

- Status: !`git status --short`
- Staged diff: !`git diff --cached`
- Unstaged diff: !`git diff`

## Instructions

1. If nothing is staged and nothing is unstaged, tell the user there is
   nothing to commit and stop.
2. If there are unstaged changes the user hasn't mentioned staging
   selectively, stage everything relevant with `git add`. Ask first if the
   diff touches files that look unrelated to each other (e.g. an unrelated
   config file mixed in with feature code) — don't silently bundle unrelated
   changes into one commit.
3. Write a commit message using [Conventional Commits](https://www.conventionalcommits.org/):
   `<type>(<scope>): <short summary>`
   - Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`, `perf`
   - Scope is optional; use it when the change is clearly limited to one
     module/feature.
   - Summary is imperative mood, lowercase, no trailing period, under 72 chars.
   - If the change needs more explanation, add a blank line then 1-3 bullet
     points describing what and why (not a line-by-line diff narration).
4. Run `git commit -m "..."`. Show the user the final message before or
   as part of the commit output.
5. Never use `git commit --amend` or force-push unless the user explicitly
   asks for it — this skill only creates new commits.

## Example

Diff shows a new rate limiter added to an API middleware file.

```
feat(api): add rate limiting to public endpoints

- caps requests per IP using a sliding window
- returns 429 with a Retry-After header when exceeded
```
