#!/bin/bash
# PostToolUse Hook: Auto-lint after file edits
#
# Runs the linter on any file the agent writes or edits.
# Catches issues immediately rather than at the end.
#
# Install: Add to .claude/settings.json under hooks.PostToolUse

INPUT=$(cat /dev/stdin)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only run after Write or Edit
if [[ "$TOOL" != "Write" && "$TOOL" != "Edit" ]]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# ========== CUSTOMIZE THIS ==========
# Detect file type and run appropriate linter
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx)
    npx eslint "$FILE_PATH" --fix 2>/dev/null
    ;;
  *.py)
    ruff check "$FILE_PATH" --fix 2>/dev/null
    ;;
  *.css|*.scss)
    npx stylelint "$FILE_PATH" --fix 2>/dev/null
    ;;
esac
# =====================================

# Always allow (lint is best-effort, don't block on failure)
exit 0
