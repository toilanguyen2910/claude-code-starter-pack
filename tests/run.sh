#!/usr/bin/env bash
#
# tests/run.sh — validates every piece of this pack before it ships.
# Exits non-zero if anything fails.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PASS=0
FAIL=0

ok()   { echo "  OK   $1"; PASS=$((PASS+1)); }
bad()  { echo "  FAIL $1"; [[ -n "${2:-}" ]] && echo "       $2"; FAIL=$((FAIL+1)); }

# Find available python command, avoiding Windows App Store execution aliases that fail when executed.
PYTHON_CMD=""
if command -v python3 &>/dev/null && python3 --version &>/dev/null; then
  PYTHON_CMD="python3"
elif command -v python &>/dev/null && python --version &>/dev/null; then
  PYTHON_CMD="python"
fi

if [[ -z "$PYTHON_CMD" ]]; then
  echo "Error: python or python3 must be installed and functioning to run these tests." >&2
  exit 1
fi

# Validates JSON files using jq or python
validate_json() {
  local f="$1"
  if command -v jq &>/dev/null; then
    jq empty "$f"
  elif [[ -n "$PYTHON_CMD" ]]; then
    "$PYTHON_CMD" -m json.tool "$f" >/dev/null
  else
    return 1
  fi
}

echo "== 1. SKILL.md frontmatter =="
for f in skills/*/SKILL.md; do
  name="$(dirname "$f" | xargs basename)"
  out=$("$PYTHON_CMD" - "$f" <<'PY' 2>&1
import sys, yaml
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
assert text.startswith("---\n"), "must start with '---'"
end = text.index("\n---\n", 4)
fm = yaml.safe_load(text[4:end+1])
assert isinstance(fm, dict), "frontmatter is not a mapping"
assert "name" in fm, "missing 'name'"
assert "description" in fm, "missing 'description'"
assert fm["name"] == path.split("/")[1], f"name '{fm['name']}' does not match directory"
print("ok")
PY
)
  if [[ "$out" == "ok" ]]; then
    ok "$name: valid frontmatter, name matches directory"
  else
    bad "$name" "$out"
  fi
done

echo "== 2. JSON files =="
for f in .claude/settings.json.example; do
  if validate_json "$f" >/dev/null 2>&1; then
    ok "$f: valid JSON"
  else
    bad "$f" "invalid JSON format"
  fi
done

echo "== 3. shellcheck =="
for f in setup.sh .claude/hooks/protect-files.sh; do
  if out=$(shellcheck -S warning "$f" 2>&1); then
    ok "$f: shellcheck clean"
  else
    bad "$f" "$out"
  fi
done

echo "== 4. protect-files.sh behavior =="
HOOK=".claude/hooks/protect-files.sh"

check_hook() {
  local path="$1" expect="$2" desc="$3"
  local code
  local tmp_log
  tmp_log=$(mktemp)
  echo "{\"tool_input\":{\"file_path\":\"$path\"}}" | "$HOOK" >"$tmp_log" 2>&1
  code=$?
  if [[ "$code" == "$expect" ]]; then
    ok "$desc (exit $code)"
  else
    bad "$desc" "expected exit $expect, got $code: $(cat "$tmp_log")"
  fi
  rm -f "$tmp_log"
}

check_hook "./src/utils.py" 0 "allows a normal source file"
check_hook "./.env" 2 "blocks .env"
check_hook "./.env.production" 2 "blocks .env.production"
check_hook "./package-lock.json" 2 "blocks package-lock.json"
check_hook "./.git/config" 2 "blocks .git/config"
check_hook "./keys/server.pem" 2 "blocks .pem files"

# empty file_path (e.g. a tool call with no file_path field) must not crash
tmp_log2=$(mktemp)
echo '{"tool_input":{}}' | "$HOOK" >"$tmp_log2" 2>&1
if [[ $? == 0 ]]; then
  ok "handles missing file_path without crashing"
else
  bad "handles missing file_path without crashing" "$(cat "$tmp_log2")"
fi
rm -f "$tmp_log2"

echo "== 5. setup.sh — personal mode, dry run =="
TMP1="$(mktemp -d)"
export HOME="$TMP1/home"
mkdir -p "$HOME"
cd "$TMP1"
if out=$("$ROOT/setup.sh" --dry-run 2>&1); then
  if [[ ! -d "$HOME/.claude" ]]; then
    ok "dry-run makes no changes to \$HOME/.claude"
  else
    bad "dry-run makes no changes to \$HOME/.claude" "directory was created"
  fi
else
  bad "setup.sh --dry-run exits clean" "$out"
fi
cd "$ROOT"

echo "== 6. setup.sh — personal mode, real run =="
TMP2="$(mktemp -d)"
export HOME="$TMP2/home"
mkdir -p "$HOME"
cd "$TMP2"
if out=$("$ROOT/setup.sh" 2>&1); then
  ok "setup.sh (personal) exits 0"
else
  bad "setup.sh (personal) exits 0" "$out"
fi
count=$(find "$HOME/.claude/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
if [[ "$count" == "4" ]]; then
  ok "installs all 4 skills to \$HOME/.claude/skills"
else
  bad "installs all 4 skills to \$HOME/.claude/skills" "found $count"
fi
if [[ -f "$TMP2/CLAUDE.md" ]]; then
  ok "creates ./CLAUDE.md from template"
else
  bad "creates ./CLAUDE.md from template" "missing"
fi
# idempotency: re-run should skip, not fail, not duplicate
if out2=$("$ROOT/setup.sh" 2>&1); then
  if echo "$out2" | grep -q "skip CLAUDE.md"; then
    ok "re-run skips existing CLAUDE.md instead of overwriting"
  else
    bad "re-run skips existing CLAUDE.md instead of overwriting" "$out2"
  fi
else
  bad "setup.sh is safe to re-run" "$out2"
fi
cd "$ROOT"

echo "== 7. setup.sh — project mode =="
TMP3="$(mktemp -d)"
export HOME="$TMP3/home"
mkdir -p "$HOME" "$TMP3/proj"
cd "$TMP3/proj"
if out=$("$ROOT/setup.sh" --project 2>&1); then
  ok "setup.sh --project exits 0"
else
  bad "setup.sh --project exits 0" "$out"
fi
count=$(find ".claude/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
[[ "$count" == "4" ]] && ok "installs 4 skills into ./.claude/skills" || bad "installs 4 skills into ./.claude/skills" "found $count"
[[ -f ".claude/settings.json" ]] && ok "creates .claude/settings.json" || bad "creates .claude/settings.json" "missing"
[[ -x ".claude/hooks/protect-files.sh" ]] && ok "copies hook and keeps it executable" || bad "copies hook and keeps it executable" "missing or not executable"
if validate_json ".claude/settings.json" >/dev/null 2>&1; then
  ok "installed settings.json is valid JSON"
else
  bad "installed settings.json is valid JSON"
fi
cd "$ROOT"
rm -rf "$TMP1" "$TMP2" "$TMP3"

echo "== 8. README <-> actual files consistency =="
for skill in commit-helper code-reviewer readme-writer bug-report; do
  if grep -q "\`$skill\`" README.md; then
    ok "README mentions skill: $skill"
  else
    bad "README mentions skill: $skill" "not found in README.md"
  fi
  if [[ -f "skills/$skill/SKILL.md" ]]; then
    ok "skill dir exists: $skill"
  else
    bad "skill dir exists: $skill" "missing skills/$skill/SKILL.md"
  fi
done

echo
echo "================================"
echo "  Passed: $PASS   Failed: $FAIL"
echo "================================"
[[ "$FAIL" == 0 ]]
