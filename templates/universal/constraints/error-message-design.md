---
name: Agent-Friendly Error Message Design Guide
description: How to design error messages that help AI agents self-correct. The difference between an agent that fixes itself and one that loops endlessly.
when_to_use: When configuring linters, build tools, or custom validation scripts that agents will encounter.
---

# Agent-Friendly Error Message Design

## The Problem

Traditional error messages are written for humans who can search docs, ask colleagues, and use context clues. AI agents take error messages literally. Vague errors cause loops.

```
BAD (agent loops):
  Error: Validation failed at line 42

GOOD (agent self-corrects):
  Error: Validation failed at src/api/users.ts:42
  Rule: max-function-length (limit: 50 lines, actual: 73 lines)
  Fix: Extract lines 45-70 into a validateUserInput() helper function
  Pattern: See src/api/orders.ts:28 for a similar extraction
  Verify: Run `npm run lint src/api/users.ts`
```

## The Five Components of an Agent-Friendly Error

| Component | Purpose | Example |
|-----------|---------|---------|
| **Location** | Exact file + line | `src/api/users.ts:42` |
| **Rule** | Which rule was violated | `max-function-length (limit: 50, actual: 73)` |
| **Fix** | Specific action to resolve | `Extract lines 45-70 into validateUserInput()` |
| **Pattern** | Reference to working example | `See src/api/orders.ts:28` |
| **Verify** | Command to confirm the fix | `Run: npm run lint src/api/users.ts` |

**Minimum**: Location + Rule + Fix. The more components you include, the faster the agent self-corrects.

## Applying to Common Tools

### ESLint Custom Rules

```javascript
// In your custom rule's `report` call:
context.report({
  node,
  message: [
    `Function "${node.id.name}" is ${lines} lines (max: ${MAX_LINES}).`,
    `Fix: Extract a helper function for the logic at lines ${start}-${end}.`,
    `Pattern: See ${exampleFile} for a similar extraction.`,
  ].join(' '),
});
```

### Custom Linter Scripts

```bash
# Instead of:
echo "ERROR: Import violation"

# Output:
echo "ERROR: src/ui/Button.tsx:5 imports from src/server/db.ts"
echo "  Rule: UI layer must not import from server layer"
echo "  Fix: Move the data fetching to a page-level component and pass as props"
echo "  Reference: See docs/ARCHITECTURE.md for layer dependency rules"
```

### Test Failure Messages

```python
# Instead of:
assert result == expected

# Use descriptive assertions:
assert result == expected, (
    f"Expected {expected}, got {result}. "
    f"Check the transform logic in src/utils/transform.py:process_data(). "
    f"Common cause: timezone conversion not applied."
)
```

## Impact

OpenAI's experience:

> "Linter error messages double as remediation instructions injected into agent context."

When every error message contains its own fix, the "violation → detection → fix" loop closes automatically. The agent doesn't need to search for solutions — the error tells it exactly what to do.
