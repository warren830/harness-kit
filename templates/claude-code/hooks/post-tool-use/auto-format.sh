#!/bin/bash
# PostToolUse Hook: Auto-format after file edits
#
# Runs the formatter on any file the agent writes or edits.
# Ensures consistent code style without the agent needing to think about it.
#
# Install: Add to .claude/settings.json under hooks.PostToolUse

INPUT=$(cat /dev/stdin)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [[ "$TOOL" != "Write" && "$TOOL" != "Edit" ]]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# ========== CUSTOMIZE THIS ==========
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md)
    npx prettier "$FILE_PATH" --write 2>/dev/null
    ;;
  *.py)
    ruff format "$FILE_PATH" 2>/dev/null
    ;;
esac
# =====================================

exit 0
