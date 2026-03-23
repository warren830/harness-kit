---
description: Systematic debugging methodology. Use when investigating bugs, errors, or unexpected behavior.
---

# Debugging Skill

## Iron Rule

**No fix without root cause.** Do not apply patches or workarounds until you understand WHY the bug exists.

## Four-Phase Process

### Phase 1: Reproduce
- Identify exact steps to trigger the bug
- Confirm the bug exists (run failing test or reproduce manually)
- Note: if you can't reproduce it, you can't verify the fix

### Phase 2: Isolate
- Find the smallest code path that triggers the bug
- Binary search: disable half the code, see if bug persists
- Check recent changes: `git log --oneline -20` — was this working before?
- Read error messages carefully — they usually point to the exact location

### Phase 3: Root Cause
- Trace data flow from input to the point of failure
- Check assumptions: null/undefined values, type mismatches, race conditions
- Check boundaries: off-by-one, empty arrays, missing keys, integer overflow
- Ask: "What changed?" — recent PRs, dependency updates, config changes

### Phase 4: Fix and Verify
- Write a test that reproduces the bug FIRST (red)
- Implement the minimal fix (green)
- Run full test suite to check for regressions
- Verify the original reproduction steps no longer fail

## Common Root Causes

| Symptom | Likely Cause | Check |
|---------|-------------|-------|
| "Cannot read property of undefined" | Null reference | Add null checks, check data source |
| "Maximum call stack exceeded" | Infinite recursion | Check base cases, circular references |
| Works locally, fails in CI | Environment difference | Node version, env vars, file paths |
| Intermittent failures | Race condition | Async ordering, shared state, timing |
| Works for some users, not others | Data-dependent | Check edge case data, permissions |

## What NOT to Do

- Don't add `try/catch` around the symptom without understanding the cause
- Don't add `if (x !== null)` guards everywhere — find why x is null
- Don't revert to a working version without understanding what broke
