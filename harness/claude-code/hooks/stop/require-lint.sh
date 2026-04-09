#!/bin/bash
# Stop Hook: Require lint to pass before agent stops
#
# Ensures the agent doesn't leave linting errors behind.
# Combine with require-tests.sh for a complete verification gate.
#
# Install: Add to .claude/settings.json under hooks.Stop

# ========== CUSTOMIZE THIS ==========
LINT_CMD="npm run lint"
# Other examples:
# LINT_CMD="ruff check ."
# LINT_CMD="pnpm lint"
# LINT_CMD="golangci-lint run"
# =====================================

if ! $LINT_CMD >/dev/null 2>&1; then
  jq -n \
    --arg reason "Lint errors found. Fix all lint issues before stopping. Run: $LINT_CMD" \
    '{decision: "block", reason: $reason}'
else
  exit 0
fi
