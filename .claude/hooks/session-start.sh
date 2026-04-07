#!/usr/bin/env bash
# SessionStart hook — primes Claude with project memory at the top of every session.
# Output to stdout becomes additionalContext for Claude.

set -euo pipefail
MEM="${CLAUDE_PROJECT_DIR:-.}/.claude/memory"

emit() {
  local file="$1"
  local label="$2"
  if [[ -f "$file" && -s "$file" ]]; then
    echo "### $label"
    # Trim to last ~80 lines so context stays bounded
    tail -n 80 "$file"
    echo
  fi
}

{
  echo "## Project memory loaded by harness"
  echo
  emit "$MEM/mistakes.md"  "Past mistakes (do NOT repeat)"
  emit "$MEM/lessons.md"   "Lessons learned"
  emit "$MEM/decisions.md" "Architectural decisions"
  echo "## End of project memory"
} 2>/dev/null || true

exit 0
