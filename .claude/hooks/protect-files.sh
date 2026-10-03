#!/bin/bash
# protect-files.sh
#
# PreToolUse hook for Edit|Write. Blocks Claude from editing files that
# should never be touched automatically: secrets, lockfiles, and anything
# under .git/. Exit 2 blocks the tool call and sends the message on stderr
# back to Claude as feedback.
#
# Registered in .claude/settings.json.example under hooks.PreToolUse.

set -euo pipefail

INPUT=$(cat)

# Extract FILE_PATH from JSON input. Supports jq, python, or grep/cut fallback.
if command -v jq &>/dev/null; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
elif command -v python3 &>/dev/null && python3 --version &>/dev/null; then
  FILE_PATH=$(echo "$INPUT" | python3 -c 'import sys, json; print(json.load(sys.stdin).get("tool_input", {}).get("file_path", ""))')
elif command -v python &>/dev/null && python --version &>/dev/null; then
  FILE_PATH=$(echo "$INPUT" | python -c 'import sys, json; print(json.load(sys.stdin).get("tool_input", {}).get("file_path", ""))')
else
  # Basic fallback using grep and cut when neither jq nor python is installed.
  FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
fi

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

PROTECTED_PATTERNS=(
  ".env"
  ".env."
  "package-lock.json"
  "yarn.lock"
  "pnpm-lock.yaml"
  ".git/"
  "id_rsa"
  ".pem"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: '$FILE_PATH' matches protected pattern '$pattern'. Edit this file manually if it's really needed." >&2
    exit 2
  fi
done

exit 0
