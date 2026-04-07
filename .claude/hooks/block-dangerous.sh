#!/usr/bin/env bash
# PreToolUse hook for Bash — blocks destructive / unsafe shell commands
# regardless of language or stack. Reads tool input as JSON on stdin.

set -euo pipefail

INPUT="$(cat)"
CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')"

if [[ -z "$CMD" ]]; then
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

# --- patterns that are always denied ---------------------------------------
patterns=(
  'rm[[:space:]]+-rf?[[:space:]]+/'              # rm -rf /
  'rm[[:space:]]+-rf?[[:space:]]+~'              # rm -rf ~
  'rm[[:space:]]+-rf?[[:space:]]+\*'             # rm -rf *
  'rm[[:space:]]+-rf?[[:space:]]+\.'             # rm -rf .
  'mkfs(\.|[[:space:]])'                          # filesystem format
  'dd[[:space:]]+if=.*of=/dev/'                   # raw disk write
  ':\(\)\{.*\}'                                   # fork bomb
  'sudo[[:space:]]'                               # sudo anything
  'chmod[[:space:]]+-R[[:space:]]+777'            # world-writable recursive
  'curl[[:space:]].*\|[[:space:]]*(sh|bash|zsh)'  # curl | sh
  'wget[[:space:]].*\|[[:space:]]*(sh|bash|zsh)' # wget | sh
  'git[[:space:]]+push[[:space:]].*--force'       # force push
  'git[[:space:]]+push[[:space:]].*[[:space:]]-f([[:space:]]|$)'
  'git[[:space:]]+reset[[:space:]]+--hard'        # destructive reset
  'git[[:space:]]+clean[[:space:]]+-fd'           # destructive clean
  '--no-verify'                                   # bypass git hooks
  '>[[:space:]]*/dev/sd[a-z]'                     # write to raw disk
)

for p in "${patterns[@]}"; do
  if [[ "$CMD" =~ $p ]]; then
    deny "Blocked by harness: command matches dangerous pattern '$p'. If you really need this, ask the user explicitly."
  fi
done

# --- writes to sensitive files ---------------------------------------------
if [[ "$CMD" =~ \>[[:space:]]*(\.env|.*\.pem|.*id_rsa|.*\.aws/credentials) ]]; then
  deny "Blocked: refusing to write to a credentials/secret file."
fi

exit 0
