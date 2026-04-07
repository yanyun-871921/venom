#!/usr/bin/env bash
# UserPromptSubmit hook — injects lightweight repo state on every prompt
# so Claude always knows the current branch / dirty state.

set -euo pipefail

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git branch --show-current 2>/dev/null || echo "(detached)")
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  echo "## Repo state"
  echo "- branch: $branch"
  echo "- uncommitted files: $dirty"
fi

exit 0
