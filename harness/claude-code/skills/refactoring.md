---
description: Safe refactoring methodology. Use when restructuring code without changing behavior.
---

# Refactoring Skill

## Core Principle

**Refactoring changes structure, not behavior.** All tests must pass before AND after. If a test breaks, something went wrong.

## Process

1. **Verify baseline**: Run all tests. They must pass. If they don't, fix tests first.
2. **Small steps**: One refactoring at a time. Commit after each successful step.
3. **Re-run tests**: After every change. No exceptions.
4. **Don't mix**: Never combine refactoring with feature changes in the same commit.

## Safe Refactoring Patterns

| Pattern | When | Technique |
|---------|------|-----------|
| Extract function | Function > 30 lines | Move block to new function, call from original |
| Extract module | File > 300 lines | Group related functions into new file, re-export |
| Rename | Name is misleading | Use IDE rename, verify all references updated |
| Inline | Unnecessary indirection | Replace function call with its body |
| Move | Wrong module/layer | Move to correct location, update all imports |
| Simplify conditional | Nested if/else > 3 levels | Early returns, guard clauses, lookup tables |

## Dependency-Safe Order

When refactoring across modules, follow dependency order (leaf → root):

```
1. Types (no deps)      ← refactor these first
2. Utilities (deps: types)
3. Repositories (deps: types)
4. Services (deps: repos, types)
5. Routes/UI (deps: services)  ← refactor these last
```

## Don't Refactor

- Code you're not tasked with changing (stay focused)
- Code with no tests (add tests first, then refactor)
- Code in protected modules (check HARNESS.md for restrictions)
