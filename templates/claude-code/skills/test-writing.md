---
description: Test writing patterns and practices. Use when creating or updating tests.
---

# Test Writing Skill

## Test Structure (Arrange-Act-Assert)

```
test("should [expected behavior] when [condition]", () => {
  // Arrange: set up test data and dependencies
  // Act: call the function or trigger the behavior
  // Assert: verify the expected outcome
})
```

## What to Test

| Priority | What | Example |
|----------|------|---------|
| 1 (must) | Happy path | Valid input produces correct output |
| 2 (must) | Error cases | Invalid input throws/returns error |
| 3 (should) | Edge cases | Empty input, null, max values, boundary conditions |
| 4 (nice) | Integration | Multiple components working together |

## Naming Convention

```
"should [expected behavior] when [condition]"

Examples:
"should return user when valid ID is provided"
"should throw NotFoundError when user does not exist"
"should return empty array when no results match"
```

## Test Isolation

- Each test must be independent — order should not matter
- Clean up after: reset mocks, clear databases, remove temp files
- Don't share state between tests
- Mock external dependencies (APIs, databases, file system)

## Common Patterns

### Testing async functions
```typescript
test("should fetch user", async () => {
  const user = await getUser("123");
  expect(user.name).toBe("Alice");
});
```

### Testing error throwing
```typescript
test("should throw on invalid input", () => {
  expect(() => validate(null)).toThrow("Input required");
});
```

### Testing with mocks
```typescript
const mockDb = { findUser: jest.fn().mockResolvedValue({ id: "123", name: "Alice" }) };
const service = new UserService(mockDb);
```

## Anti-patterns

- Don't test implementation details (private methods, internal state)
- Don't write tests that pass regardless of code changes (tautological tests)
- Don't use random/time-dependent data without seeding
- Don't test framework behavior (e.g., "React renders a div")
