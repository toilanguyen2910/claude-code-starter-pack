# Hooks

Claude Code hooks let you run scripts at specific points during a session.
This pack includes one hook and one notification example.

## Included hooks

### `protect-files.sh` (PreToolUse)

Blocks Claude from editing sensitive files:

- `.env` and `.env.*` — environment secrets
- `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` — lockfiles
- `.git/` — git internals
- `id_rsa`, `.pem` — private keys

When a file is blocked, the hook sends a message back to Claude explaining
why, so it can route around the block instead of retrying.

### Idle notification (Notification)

Prints a line to stderr when Claude is done and waiting for input. Useful
when Claude is running a long task and you want to know when it's your turn.

## How hooks are configured

Hooks are registered in `.claude/settings.json` under the `hooks` key:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh"
          }
        ]
      }
    ]
  }
}
```

## Writing your own hook

1. Create a script in `.claude/hooks/`.
2. The script receives tool input as JSON on stdin.
3. Exit codes:
   - `0` — allow the operation
   - `2` — block the operation (stderr is sent back to Claude as feedback)
4. Register the hook in `.claude/settings.json`.

## Example: blocking a specific directory

```bash
#!/bin/bash
set -euo pipefail
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
if [[ "$FILE_PATH" == *"vendor/"* ]]; then
  echo "Blocked: don't edit vendored dependencies." >&2
  exit 2
fi
exit 0
```
