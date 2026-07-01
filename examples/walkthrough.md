# Walkthrough: using all four skills in a session

This example shows how a typical session might use each skill from the
starter pack. The project is a small Node.js API.

---

## 1. Generate a README (`readme-writer`)

```
> Write a README for this project.
```

Claude activates `readme-writer`, inspects `package.json` and the source
tree, and generates a `README.md` grounded in what's actually there — no
invented features or placeholder badges.

---

## 2. Review your changes (`code-reviewer`)

After making some edits:

```
> Review my changes before I commit.
```

Claude activates `code-reviewer`, runs `git diff HEAD`, and goes through
the checklist: correctness, error handling, security, resource management,
naming, and test coverage. Output looks like:

```
- **Severity**: blocker
  **Location**: src/middleware/auth.js:42
  **Issue**: JWT secret is hardcoded as a string literal.
  **Fix**: Move to an environment variable and read via `process.env.JWT_SECRET`.

Summary: 1 blocker, 2 suggestions. Fix the blocker before committing.
```

---

## 3. Fix the issue and commit (`commit-helper`)

After fixing the JWT secret:

```
> Commit this.
```

Claude activates `commit-helper`, stages the changes, reads the diff,
and writes:

```
fix(auth): move JWT secret to environment variable

- removes hardcoded secret from auth middleware
- reads from process.env.JWT_SECRET at startup
```

---

## 4. File a bug report (`bug-report`)

A user reports a problem:

```
> /bug-report Users get a 500 error when signing up with a Gmail address
```

Claude activates `bug-report` and produces:

```markdown
## Summary
Users receive a 500 Internal Server Error when creating an account with
a Gmail address.

## Steps to reproduce
1. Navigate to /signup
2. Enter a Gmail address (e.g. user@gmail.com)
3. Fill in remaining fields and submit

## Expected behavior
Account is created and user is redirected to the dashboard.

## Actual behavior
Server returns 500. No account is created.

## Environment
- Node.js API running locally
- Version: commit abc1234
```

If the codebase suggests a likely cause, Claude adds a **Suspected cause**
section with file and line references.
