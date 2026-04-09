---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/__tests__/**"
  - "tests/**"
---

# Test Writing Rules

- Use Arrange-Act-Assert pattern in every test
- Test names: "should [expected behavior] when [condition]"
- Each test must be independent — no shared mutable state between tests
- Mock external dependencies (APIs, databases) — don't make real network calls in unit tests
- Don't test implementation details (private methods, internal state) — test behavior
- Every bug fix must include a regression test that would have caught the bug
