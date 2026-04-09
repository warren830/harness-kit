#!/bin/bash
# PreToolUse Hook: Restrict edits to protected directories
#
# Blocks the agent from modifying files in specified protected paths.
# Customize PROTECTED_PATHS below for your project.
#
# Install: Add to .claude/settings.json under hooks.PreToolUse

INPUT=$(cat /dev/stdin)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only check Write and Edit tools
if [[ "$TOOL" != "Write" && "$TOOL" != "Edit" ]]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# ========== CUSTOMIZE THIS ==========
# Add paths that agents should NOT modify without explicit approval
PROTECTED_PATHS=(
  "src/core/"
  "prisma/schema.prisma"
  "src/auth/"
  ".env"
  "package-lock.json"
  "pnpm-lock.yaml"
)
# =====================================

for protected in "${PROTECTED_PATHS[@]}"; do
  if echo "$FILE_PATH" | grep -q "$protected"; then
    jq -n \
      --arg reason "Blocked: $FILE_PATH is in a protected path ($protected). This file requires explicit user approval to modify." \
      '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
    exit 0
  fi
done

exit 0
