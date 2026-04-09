---
inclusion: manual
---

# Debugging Guide

> Load this with `#debugging-guide` in Kiro chat when investigating a bug.

## Process

### 1. Reproduce
- Identify exact steps to trigger the bug
- Confirm it's reproducible (not intermittent)

### 2. Isolate
- Find smallest code path that triggers it
- Check recent changes: `git log --oneline -20`
- Binary search: disable half the code, does bug persist?

### 3. Root Cause
- Trace data flow from input to failure point
- Check: null values, type mismatches, race conditions, off-by-one
- Ask: what changed recently?

### 4. Fix
- Write a test that reproduces the bug first (red)
- Implement minimal fix (green)
- Run full test suite (no regressions)

## Common Causes

| Symptom | Check |
|---------|-------|
| "undefined is not an object" | Null reference — trace where data comes from |
| Works locally, fails in CI | Environment diff — node version, env vars |
| Intermittent failures | Race condition — async ordering, shared state |
| Works for some users | Data-dependent — check edge case data |

## Iron Rule

**No fix without root cause.** Don't wrap in try/catch. Don't add null guards everywhere. Find WHY it's null.
