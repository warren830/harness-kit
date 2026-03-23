---
name: Kiro Hook — Run Tests After Task Completion
description: Automatically run tests after each spec task completes. Ensures each step is verified.
---

# Kiro Hook: Test After Task

## Setup

Create this hook via Kiro's Command Palette → "Kiro: Open Kiro Hook UI":

| Field | Value |
|-------|-------|
| **Title** | Run Tests After Task |
| **Description** | Run test suite after each spec task completes to verify the step |
| **Event** | After Spec Task Execution |
| **Action Type** | Run Command |
| **Command** | `npm test -- --watchAll=false` |

## Why This Hook?

Kiro's Specs break work into discrete tasks. This hook ensures each task is verified before moving to the next. Without it, errors from early tasks compound into later tasks.

```
Task 1: Create schema    →  run tests  →  pass  →  continue
Task 2: Create service   →  run tests  →  FAIL  →  fix before Task 3
Task 3: Create API route →  (only starts after Task 2 passes)
```

## Alternative: Ask Kiro

| Field | Value |
|-------|-------|
| **Action Type** | Ask Kiro |
| **Instructions** | The spec task just completed. Run the test suite and verify all tests pass. If any test fails, analyze the failure and suggest a fix before proceeding to the next task. |
