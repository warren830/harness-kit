#!/bin/bash
# Stop Hook: Require tests to pass before agent stops
#
# This is the HIGHEST-IMPACT hook. It forces the agent to verify its own work
# before declaring "done". Without this, agents frequently skip verification.
#
# "Self-verification is the single highest-leverage thing you can do."
# — Anthropic best practices
#
# Install: Add to .claude/settings.json under hooks.Stop

# ========== CUSTOMIZE THIS ==========
TEST_CMD="npm test -- --watchAll=false"
# Other examples:
# TEST_CMD="pytest -x -q"
# TEST_CMD="pnpm test -- --watchAll=false"
# TEST_CMD="go test ./..."
# =====================================

if ! $TEST_CMD >/dev/null 2>&1; then
  # Output JSON that blocks the stop and tells the agent why
  jq -n \
    --arg reason "Tests are failing. Fix all test failures before stopping. Run: $TEST_CMD" \
    '{decision: "block", reason: $reason}'
else
  exit 0
fi
