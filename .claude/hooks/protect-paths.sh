#!/usr/bin/env bash
# PreToolUse hook for Write|Edit — refuses to write to protected paths
# (secrets, lockfiles, generated artifacts, OS dirs).

set -euo pipefail

INPUT="$(cat)"
PATH_ARG="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

if [[ -z "$PATH_ARG" ]]; then
  exit 0
fi

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

case "$PATH_ARG" in
  /etc/*|/usr/*|/bin/*|/sbin/*|/boot/*|/sys/*|/proc/*)
    deny "Blocked: refusing to write to system path '$PATH_ARG'." ;;
  */.git/*)
    deny "Blocked: refusing to write inside .git/. Use git commands instead." ;;
  */.env|*/.env.*|*/id_rsa|*/id_ed25519|*/.aws/credentials|*/.ssh/*)
    deny "Blocked: refusing to write to a secrets/credentials file." ;;
  */node_modules/*|*/vendor/*|*/.venv/*|*/dist/*|*/build/*|*/.next/*|*/target/*)
    deny "Blocked: refusing to write inside a generated/dependency directory ('$PATH_ARG'). Edit source files instead." ;;
  *package-lock.json|*yarn.lock|*pnpm-lock.yaml|*Cargo.lock|*poetry.lock|*Pipfile.lock|*go.sum)
    deny "Blocked: refusing to hand-edit lockfile '$PATH_ARG'. Use the package manager instead." ;;
esac

exit 0
