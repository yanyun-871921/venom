#!/usr/bin/env bash
# PostToolUse hook for Write|Edit — auto-formats edited file using whatever
# formatter is available for its extension. Silent if no formatter is found.
# Language-agnostic: detects, but never installs.

set -euo pipefail

INPUT="$(cat)"
FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

[[ -z "$FILE" || ! -f "$FILE" ]] && exit 0

have() { command -v "$1" >/dev/null 2>&1; }
run() { "$@" >/dev/null 2>&1 || true; }

case "$FILE" in
  *.py)
    if have ruff; then run ruff format "$FILE"; run ruff check --fix "$FILE"
    elif have black; then run black -q "$FILE"; fi ;;
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.json|*.css|*.scss|*.html|*.md|*.yml|*.yaml)
    if have prettier; then run prettier --write "$FILE"; fi ;;
  *.go)
    have gofmt && run gofmt -w "$FILE"
    have goimports && run goimports -w "$FILE" ;;
  *.rs)
    have rustfmt && run rustfmt --edition 2021 "$FILE" ;;
  *.rb)
    have rubocop && run rubocop -A "$FILE" ;;
  *.sh|*.bash)
    have shfmt && run shfmt -w "$FILE" ;;
  *.tf)
    have terraform && run terraform fmt "$FILE" ;;
esac

exit 0
