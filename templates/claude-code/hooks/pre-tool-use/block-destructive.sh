#!/bin/bash
# PreToolUse Hook: Block destructive commands
#
# Prevents the agent from running dangerous commands like:
# - rm -rf (recursive delete)
# - git push --force (overwrite remote history)
# - git reset --hard (discard local changes)
# - DROP TABLE / DROP DATABASE (database destruction)
#
# Install: Add to .claude/settings.json under hooks.PreToolUse
# Test: echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | bash block-destructive.sh

INPUT=$(cat /dev/stdin)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only check Bash commands
if [[ "$TOOL" != "Bash" ]]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Destructive patterns to block
BLOCKED_PATTERNS=(
  'rm -rf'
  'rm -fr'
  'rmdir -rf'
  'git push.*--force'
  'git push.*-f'
  'git reset --hard'
  'git clean -fd'
  'git checkout \.'
  'DROP TABLE'
  'DROP DATABASE'
  'TRUNCATE TABLE'
  'DELETE FROM .* WHERE 1'
  'chmod -R 777'
  'mkfs\.'
  '> /dev/sd'
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    jq -n \
      --arg reason "Blocked destructive command matching pattern: $pattern. If you need to run this, ask the user for explicit confirmation." \
      '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
    exit 0
  fi
done

# Allow all other commands
exit 0
