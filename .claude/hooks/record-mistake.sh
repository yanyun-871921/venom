#!/usr/bin/env bash
# PostToolUseFailure hook — automatically appends failures to mistakes.md
# so Claude can read them on the next SessionStart and avoid repeating them.

set -euo pipefail

INPUT="$(cat)"
TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // "unknown"')"
ERR="$(printf '%s' "$INPUT" | jq -r '.tool_response.error // .tool_response // "(no error text)"' | head -c 500)"
CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // .tool_input.file_path // .tool_input // ""' | head -c 300)"

MEM_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/memory"
mkdir -p "$MEM_DIR"
FILE="$MEM_DIR/mistakes.md"

[[ ! -f "$FILE" ]] && {
  echo "# Mistakes Log"            >  "$FILE"
  echo                              >> "$FILE"
  echo "Auto-recorded failures. Read on every session start." >> "$FILE"
  echo                              >> "$FILE"
}

{
  echo "## $(date -u +%Y-%m-%dT%H:%M:%SZ) — $TOOL failed"
  echo "- input: \`$(printf '%s' "$CMD" | tr '\n' ' ')\`"
  echo "- error: $(printf '%s' "$ERR" | tr '\n' ' ')"
  echo "- lesson: (Claude should fill this in next turn)"
  echo
} >> "$FILE"

# Tell Claude what just happened
jq -n --arg msg "Failure recorded to .claude/memory/mistakes.md. Please read it, diagnose the root cause, and update the 'lesson' line before retrying." \
  '{ systemMessage: $msg }'

exit 0
