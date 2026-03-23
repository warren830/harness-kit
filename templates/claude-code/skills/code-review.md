---
description: Systematic code review methodology. Use when reviewing code changes, PRs, or auditing code quality.
---

# Code Review Skill

## Review Checklist

For each file changed, check in order:

1. **Correctness**: Does the logic do what it claims? Edge cases handled?
2. **Architecture**: Does it respect layer boundaries? Any new cross-layer imports?
3. **Security**: User input validated? SQL injection? XSS? Secrets exposed?
4. **Tests**: Are changes covered by tests? Do existing tests still make sense?
5. **Naming**: Are names clear and consistent with project conventions?
6. **Error handling**: Are errors caught, logged, and surfaced appropriately?

## Severity Levels

- **BLOCKER**: Must fix before merge (security vulnerability, data loss risk, broken functionality)
- **BUG**: Likely bug that should be fixed (logic error, edge case, race condition)
- **SUGGESTION**: Improvement that can be deferred (readability, performance, style)
- **NIT**: Minor style preference (optional to fix)

## Review Output Format

```
## [filename]

**[SEVERITY]** Line [N]: [description]
Suggestion: [how to fix]
```

## Anti-patterns to Flag

- Functions > 50 lines (suggest extraction)
- Deeply nested conditionals > 3 levels (suggest early returns)
- Duplicated logic across files (suggest shared utility)
- TODO/FIXME without issue reference
- Commented-out code (suggest removal)
- `any` type in TypeScript / missing type annotations in Python
