---
inclusion: auto
name: testing-patterns
description: Test writing patterns, conventions, and anti-patterns. Use when creating or modifying tests.
---

# Testing Patterns

## Test Structure

```typescript
test("should [behavior] when [condition]", () => {
  // Arrange
  const input = createTestUser({ role: "admin" });

  // Act
  const result = validatePermission(input, "delete");

  // Assert
  expect(result).toBe(true);
});
```

## Priority

1. **Happy path** — valid input, expected output (must have)
2. **Error cases** — invalid input, error thrown (must have)
3. **Edge cases** — null, empty, boundary values (should have)
4. **Integration** — multiple components together (nice to have)

## Rules

- Each test is independent — no shared mutable state
- Test names: `"should [expected] when [condition]"`
- Mock external dependencies (APIs, DB) — no real network calls
- Every bug fix includes a regression test
- Don't test framework behavior or implementation details

## Anti-Patterns

- Tests that pass regardless of code changes
- Tests that depend on execution order
- Testing private methods directly
- Random/time-dependent data without seeds
