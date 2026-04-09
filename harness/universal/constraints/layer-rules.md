---
name: Layered Architecture Dependency Rules Template
description: Define which modules can import from which. Prevents agents from violating architectural boundaries.
when_to_use: Projects with 2+ layers or modules that have dependency rules.
---

# Layered Architecture Dependency Rules

## Define Your Layers

<!-- Customize this for your project. Order from most independent (bottom) to most dependent (top). -->

```
Layer 4: UI / Pages        — Can import: Services, Types
Layer 3: Services          — Can import: Repositories, Types
Layer 2: Repositories      — Can import: Types
Layer 1: Types / Schemas   — Can import: Nothing (leaf layer)
```

**Rule: Dependencies flow DOWN only. A layer must never import from a layer above it.**

## Dependency Matrix

| Importing From → | Types | Repositories | Services | UI |
|------------------|-------|-------------|----------|-----|
| **Types** | - | NO | NO | NO |
| **Repositories** | YES | - | NO | NO |
| **Services** | YES | YES | - | NO |
| **UI** | YES | NO | YES | - |

## Common Violations and How to Fix

| Violation | Example | Fix |
|-----------|---------|-----|
| UI imports Repository | `import { db } from '../repositories/db'` | Move data fetching to a Service, pass data to UI as props |
| Service imports UI component | `import { Button } from '../components'` | Extract shared logic into Types or a utility module |
| Repository imports Service | `import { calculatePrice } from '../services'` | Move calculation to Types as a pure function |
| Circular dependency | A imports B, B imports A | Extract shared logic into a lower layer |

## Enforcement Options

### 1. AGENTS.md Rule (soft — ~90% compliance)
```markdown
## Architecture Rules
- UI must NOT import from repositories/
- Services must NOT import from UI/
```

### 2. ESLint Rule (hard — 100% enforced)
```javascript
// eslint-plugin-import settings
"import/no-restricted-paths": ["error", {
  zones: [
    { target: "./src/types",        from: "./src/repositories" },
    { target: "./src/types",        from: "./src/services" },
    { target: "./src/types",        from: "./src/ui" },
    { target: "./src/repositories", from: "./src/services" },
    { target: "./src/repositories", from: "./src/ui" },
    { target: "./src/services",     from: "./src/ui" },
  ]
}]
```

### 3. Structural Test (hard — 100% enforced, more flexible)
```typescript
// architecture.test.ts
import { getImports } from './test-utils';

test('UI layer does not import from repositories', () => {
  const uiImports = getImports('src/ui/**/*.ts');
  const violations = uiImports.filter(i => i.includes('src/repositories'));
  expect(violations).toEqual([]);
});
```
