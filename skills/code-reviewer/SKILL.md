---
name: code-reviewer
description: Reviews uncommitted changes or a specified file for bugs, security issues, and style problems before commit or PR. Use when the user asks to review code, check for issues, or says "does this look right".
allowed-tools: Read Grep Glob Bash(git diff *)
---

# Code reviewer

## Scope

- If the user names a file or directory, review that.
- Otherwise, review the current uncommitted diff: !`git diff HEAD`
- If the diff is empty, say so and ask what to review instead of guessing.

## Review checklist

Go through each item below. Only report what's actually present — don't pad
the review with boilerplate reassurances about things that are fine.

1. **Correctness** — logic errors, off-by-one, wrong operator, unhandled
   edge cases (empty input, null/None, zero, negative numbers).
2. **Error handling** — swallowed exceptions, missing error checks on I/O
   or network calls, unclear error messages.
3. **Security** — unsanitized input reaching a shell/SQL/HTML sink,
   hardcoded secrets or API keys, missing auth checks.
4. **Resource management** — unclosed files/connections, unbounded loops,
   memory that grows without limit.
5. **Naming and readability** — names that don't match what the code does,
   functions doing more than one thing, magic numbers without explanation.
6. **Tests** — new logic without a corresponding test, or a test that
   doesn't actually exercise the changed behavior.

## Output format

For each issue found:

- **Severity**: blocker / suggestion / nitpick
- **Location**: file:line
- **Issue**: one sentence
- **Fix**: a concrete suggestion, not just "consider fixing this"

End with a one-line summary: how many blockers, how many suggestions, and
whether the change looks safe to commit as-is.

If there are no issues, say so plainly in one or two sentences instead of
inventing minor nitpicks to fill space.
