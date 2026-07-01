#!/usr/bin/env bash
#
# setup.sh — install claude-code-starter-pack into a project or into your
# personal (~/.claude) Claude Code config.
#
# Usage:
#   ./setup.sh              Install skills to ~/.claude/skills (all your projects)
#                            and copy CLAUDE.md.template to ./CLAUDE.md if missing.
#   ./setup.sh --project     Install skills + hooks into ./.claude (this project only).
#   ./setup.sh --dry-run     Show what would happen without copying anything.
#   ./setup.sh --help        Show this help.
#
# Safe to re-run: existing files are never overwritten without --force.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="personal"
DRY_RUN=false
FORCE=false

print_help() {
  sed -n '2,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
  case "$arg" in
    --project) MODE="project" ;;
    --dry-run) DRY_RUN=true ;;
    --force) FORCE=true ;;
    --help|-h) print_help; exit 0 ;;
    *)
      echo "Unknown option: $arg" >&2
      print_help
      exit 1
      ;;
  esac
done

log() { echo "  $*"; }
act() {
  # act <description> <command...>
  local desc="$1"; shift
  if $DRY_RUN; then
    log "[dry-run] $desc"
  else
    log "$desc"
    "$@"
  fi
}

copy_skill() {
  local skill_name="$1" dest_root="$2"
  local src="$SCRIPT_DIR/skills/$skill_name"
  local dest="$dest_root/skills/$skill_name"

  if [[ -e "$dest" ]] && ! $FORCE; then
    log "skip $skill_name (already exists at $dest, use --force to overwrite)"
    return
  fi

  if $DRY_RUN; then
    log "[dry-run] copy $skill_name -> $dest"
  else
    mkdir -p "$dest_root/skills"
    rm -rf "$dest"
    cp -r "$src" "$dest"
    log "installed skill: $skill_name -> $dest"
  fi
}

echo "claude-code-starter-pack setup"
echo "mode: $MODE${DRY_RUN:+ (dry run)}"
echo

if [[ "$MODE" == "personal" ]]; then
  DEST_ROOT="$HOME/.claude"
  echo "Installing skills to $DEST_ROOT/skills (available in every project)"
  for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    skill_name="$(basename "$skill_dir")"
    copy_skill "$skill_name" "$DEST_ROOT"
  done

  echo
  if [[ -f "./CLAUDE.md" ]] && ! $FORCE; then
    log "skip CLAUDE.md (already exists in current directory, use --force to overwrite)"
  else
    act "copy CLAUDE.md.template -> ./CLAUDE.md" cp "$SCRIPT_DIR/CLAUDE.md.template" "./CLAUDE.md"
  fi

else
  DEST_ROOT="$(pwd)/.claude"
  echo "Installing skills + hooks to $DEST_ROOT (this project only)"
  for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    skill_name="$(basename "$skill_dir")"
    copy_skill "$skill_name" "$DEST_ROOT"
  done

  echo
  if [[ -f "$DEST_ROOT/settings.json" ]] && ! $FORCE; then
    log "skip .claude/settings.json (already exists, use --force to overwrite)"
  else
    act "copy .claude/settings.json.example -> .claude/settings.json" bash -c \
      "mkdir -p '$DEST_ROOT' && cp '$SCRIPT_DIR/.claude/settings.json.example' '$DEST_ROOT/settings.json'"
  fi

  if [[ -d "$DEST_ROOT/hooks" ]] && ! $FORCE; then
    log "skip .claude/hooks (already exists, use --force to overwrite)"
  else
    act "copy .claude/hooks -> .claude/hooks" bash -c \
      "mkdir -p '$DEST_ROOT' && rm -rf '$DEST_ROOT/hooks' && cp -r '$SCRIPT_DIR/.claude/hooks' '$DEST_ROOT/hooks' && chmod +x '$DEST_ROOT/hooks/'*.sh"
  fi

  echo
  if [[ -f "./CLAUDE.md" ]] && ! $FORCE; then
    log "skip CLAUDE.md (already exists in current directory, use --force to overwrite)"
  else
    act "copy CLAUDE.md.template -> ./CLAUDE.md" cp "$SCRIPT_DIR/CLAUDE.md.template" "./CLAUDE.md"
  fi
fi

echo
echo "Done. Next steps:"
echo "  1. Edit ./CLAUDE.md and fill in your project's details."
if [[ "$MODE" == "project" ]]; then
  echo "  2. Run 'claude' in this directory, then type /hooks to confirm the hooks loaded."
else
  echo "  2. Run 'claude' in any project — the skills are now available everywhere."
fi
echo "  3. Type /skills inside a session to see the installed skills."
