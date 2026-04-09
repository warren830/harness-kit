#!/bin/bash
# Stop Hook: Verify work against a completion checklist before agent stops
#
# This goes BEYOND test/lint gates. It checks: "Did I actually do what was asked?"
# Reads a project-level checklist file and verifies the agent addressed each item.
#
# Based on LangChain's PreCompletionChecklistMiddleware pattern, which contributed
# to their 13.7 percentage point improvement on Terminal Bench 2.0.
#
# Install: Add to .claude/settings.json under hooks.Stop
#
# ALTERNATIVE: For LLM-judgment verification (not mechanical matching), use a
# prompt-type hook instead of this script:
#
#   {
#     "type": "prompt",
#     "prompt": "Before finishing, verify: 1) Every requirement from the original
#       request is addressed. 2) No requirements were skipped or partially done.
#       3) You ran tests and checked output. List anything incomplete."
#   }
#
# The prompt approach is probabilistic but catches semantic gaps this script cannot.
# Best practice: use BOTH this script AND the prompt hook together.

# ========== CUSTOMIZE THIS ==========
CHECKLIST_FILE=".claude/completion-checklist.md"
# Format: one requirement per line, starting with "- [ ]" or "- "
# Example .claude/completion-checklist.md:
#   - [ ] All new functions have tests
#   - [ ] API changes are documented
#   - [ ] No console.log left in production code
# =====================================

# If no checklist file exists, pass silently (opt-in behavior)
if [[ ! -f "$CHECKLIST_FILE" ]]; then
  exit 0
fi

# Read checklist items (strip markdown checkbox syntax, skip empty lines and comments)
ITEMS=$(grep -E '^\s*-\s' "$CHECKLIST_FILE" | sed 's/^\s*-\s*\[.\]\s*//' | sed 's/^\s*-\s*//' | grep -v '^$' | grep -v '^#')

if [[ -z "$ITEMS" ]]; then
  exit 0
fi

ITEM_COUNT=$(echo "$ITEMS" | wc -l | tr -d ' ')

jq -n \
  --arg reason "Pre-completion checklist ($CHECKLIST_FILE) has $ITEM_COUNT items. Review each item and confirm you addressed it. If any item is not applicable, explain why. Checklist:
$ITEMS" \
  '{decision: "block", reason: $reason}'
