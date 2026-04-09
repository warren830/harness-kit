#!/bin/bash
# PostToolUse Hook: Detect agent editing the same file repeatedly
#
# Tracks per-file edit counts across a session. After N edits to the same file,
# outputs an advisory message nudging the agent to reconsider its approach.
#
# Based on LangChain's LoopDetectionMiddleware pattern:
# "Tracks per-file edit counts via tool call hooks, adds context like
# 'consider reconsidering your approach' after N edits to same file."
#
# Install: Add to .claude/settings.json under hooks.PostToolUse

# ========== CUSTOMIZE THIS ==========
MAX_EDITS=5          # Warn after this many edits to the same file
STATE_DIR="/tmp/harness-loop-detection"
# =====================================

INPUT=$(cat /dev/stdin)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only track Write and Edit operations
if [[ "$TOOL" != "Write" && "$TOOL" != "Edit" ]]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Create state directory if needed
mkdir -p "$STATE_DIR"

# Sanitize file path for use as filename (replace / with __)
STATE_FILE="$STATE_DIR/$(echo "$FILE_PATH" | sed 's|/|__|g')"

# Read current count (0 if file doesn't exist)
COUNT=0
if [[ -f "$STATE_FILE" ]]; then
  COUNT=$(cat "$STATE_FILE")
fi

# Increment
COUNT=$((COUNT + 1))
echo "$COUNT" > "$STATE_FILE"

# Check threshold
if [[ $COUNT -ge $MAX_EDITS ]]; then
  # Reset counter so warning repeats every N edits, not every edit after N
  echo "0" > "$STATE_FILE"

  jq -n \
    --arg file "$FILE_PATH" \
    --argjson count "$COUNT" \
    --arg msg "You have edited $FILE_PATH $COUNT times this session. This may indicate you are stuck in a loop. Step back and consider: (1) Is your current approach working? (2) Should you try a fundamentally different strategy? (3) Are you fixing symptoms instead of the root cause?" \
    '{loopDetection: {file: $file, editCount: $count, advisory: $msg}}'
fi

# Always allow — this is advisory, not blocking
exit 0
