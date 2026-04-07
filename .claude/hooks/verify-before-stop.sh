#!/usr/bin/env bash
# Stop hook — final sanity gate before Claude ends its turn.
# Reminds Claude to run verification, but never blocks twice in a row.

set -euo pipefail

INPUT="$(cat)"
STOP_HOOK_ACTIVE="$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false')"

# Avoid infinite loop: only intervene the first time.
if [[ "$STOP_HOOK_ACTIVE" == "true" ]]; then
  exit 0
fi

REPO="${CLAUDE_PROJECT_DIR:-.}"

# If there are uncommitted changes AND the project has a known test target,
# nudge Claude to verify before declaring done.
if command -v git >/dev/null 2>&1 && git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  dirty=$(git -C "$REPO" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$dirty" -gt 0 ]]; then
    has_tests=false
    for marker in package.json pyproject.toml Cargo.toml go.mod Gemfile pom.xml build.gradle; do
      [[ -f "$REPO/$marker" ]] && has_tests=true && break
    done

    if $has_tests; then
      jq -n '{
        decision: "block",
        reason: "Stop blocked by harness: there are uncommitted changes in a project that has a build/test system. Before ending, please (1) run the project test/lint/typecheck command, (2) summarize what was changed and what was verified, (3) update .claude/memory/lessons.md if you learned something durable. Then you may stop."
      }'
      exit 0
    fi
  fi
fi

exit 0
