---
name: bug-report
description: Turns a description of broken behavior into a structured bug report with reproduction steps, and optionally investigates the likely cause in the codebase. Use when the user reports something is broken, wants to file an issue, or asks to debug a problem.
argument-hint: "[short description of the bug]"
---

# Bug report

## Step 1: Structure the report

Turn $ARGUMENTS (or the user's most recent description) into this format:

```
## Summary
One sentence: what's broken.

## Steps to reproduce
1. ...
2. ...
3. ...

## Expected behavior
What should happen.

## Actual behavior
What happens instead, including exact error messages or stack traces if any.

## Environment
- OS / platform:
- Version / commit:
- Relevant config:
```

If the user's description is missing pieces (no repro steps, no expected
vs. actual distinction), ask for the minimum needed to fill the template
rather than inventing plausible-sounding steps.

## Step 2: Investigate (only if asked, or if the fix looks quick)

1. Search the codebase for the error message, function name, or relevant
   keywords using Grep/Glob.
2. Read the surrounding code to form a hypothesis about the cause.
3. State the hypothesis explicitly and how confident you are — don't
   present a guess as a confirmed diagnosis.
4. If you can reproduce it locally (e.g. a script or test), do so before
   proposing a fix.

## Step 3: Output

- If this is going into an issue tracker, output the report as a single
  markdown block ready to paste.
- If investigation found a likely cause, add a **Suspected cause** section
  with file:line references, separate from the user-facing report.
- Don't open a fix without being asked — this skill's job is to produce a
  clear report, not to silently patch things.
