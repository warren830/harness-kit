---
description: CI/CD failure diagnosis and fix patterns. Use when CI pipeline fails.
---

# CI Fix Skill

## Diagnosis Process

1. **Read the error** — CI logs tell you exactly what failed. Don't guess.
2. **Categorize** — Which step failed? (lint, type check, test, build, deploy)
3. **Reproduce locally** — Run the same command locally before attempting a fix.
4. **Fix and push** — Apply minimal fix. Don't refactor other things.

## Common CI Failure Categories

### Lint failures
```
Cause: Agent introduced code that doesn't match style rules.
Fix: Run linter with --fix flag locally, commit the result.
Command: npm run lint -- --fix  /  ruff check . --fix
```

### Type errors
```
Cause: Type mismatch, missing types, or strict mode violation.
Fix: Fix the type error. Don't add `any` or `// @ts-ignore`.
Command: npx tsc --noEmit  /  mypy .
```

### Test failures
```
Cause: Code change broke an existing test, or new code lacks tests.
Fix: Read the test failure message. Fix the code or update the test (if the test was wrong).
Command: npm test  /  pytest -x (stop at first failure)
```

### Build failures
```
Cause: Import errors, missing dependencies, environment differences.
Fix: Check imports, run install, verify env vars.
Command: npm run build  /  python setup.py build
```

## Stripe Rule: Maximum 2 Rounds

If CI still fails after 2 fix attempts, **stop and escalate to the human**. Don't loop endlessly trying different fixes — diminishing returns set in fast.
