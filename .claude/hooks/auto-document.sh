#!/bin/bash
# Stop hook — fires when a Claude Code session ends cleanly.
# Calls claude -p with the transcript to generate a structured session doc.
# Blocked by stop_hook_active guard to prevent infinite loops.

INPUT=$(cat)

# Required guard: prevents infinite loop if claude -p itself triggers Stop
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi

TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Skip if missing required fields
[ -z "$TRANSCRIPT" ] && exit 0
[ -z "$CWD" ] && exit 0
[ ! -f "$TRANSCRIPT" ] && exit 0

MAIN_WORKTREE=$(git -C "$CWD" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2; exit}')
PROJECT=$(basename "${MAIN_WORKTREE:-$CWD}")
DATE=$(date +%F)
LOG_DIR="$HOME/claude-dev-logs/$PROJECT"
SKILL="$HOME/.claude/skills/document-session.md"

mkdir -p "$LOG_DIR"

# Skip if no skill file
[ ! -f "$SKILL" ] && exit 0

INSTRUCTIONS=$(cat "$SKILL")

# Generate session doc — fail silently so it never blocks the stop
claude -p "$INSTRUCTIONS" --input-file "$TRANSCRIPT" \
  > "$LOG_DIR/session-$DATE.md" 2>/dev/null || rm -f "$LOG_DIR/session-$DATE.md"

exit 0
