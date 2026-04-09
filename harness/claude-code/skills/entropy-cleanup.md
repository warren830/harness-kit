---
description: Codebase entropy cleanup methodology. Use when cleaning up drift, dead code, stale docs, or rule conflicts.
---

# Entropy Cleanup Skill

## What Is Entropy?

Entropy is the natural degradation of codebase quality over time:
- Documentation that no longer matches implementation
- Architectural patterns that diverge across modules
- Rule files with contradictory or outdated instructions
- Dead code and unused dependencies
- TODO/FIXME comments that are months old

## Cleanup Process

### 1. Scan (identify)
```bash
# Run entropy scanner
harness-kit scan .

# Manual checks:
grep -r "TODO\|FIXME\|HACK\|TEMP" src/  # stale TODOs
grep -r "deprecated" src/                 # deprecated usage
```

### 2. Categorize (prioritize)
| Category | Impact | Priority |
|----------|--------|----------|
| Docs say X, code does Y | High — agents follow wrong docs | Fix now |
| Rule file contradictions | High — agents get confused | Fix now |
| Dead code | Low — clutters but doesn't break | Fix when convenient |
| Stale TODOs | Low — noise | Batch cleanup |
| Unused dependencies | Medium — security + bloat | Monthly cleanup |

### 3. Fix (one at a time)
- One fix per commit — easy to revert if something breaks
- Update HARNESS.md if the cleanup changes any documented behavior
- Update ARCHITECTURE.md if module structure changed
- Run full test suite after each fix

### 4. Prevent (reduce future entropy)
- Add the failure pattern to HARNESS.md (error-driven writing)
- Add a linter rule if the pattern is mechanically detectable
- Schedule regular cleanup (weekly 30-min review)

## Weekly Entropy Review Checklist

- [ ] Does HARNESS.md still match reality? (commands, paths, conventions)
- [ ] Do any docs reference files/functions that no longer exist?
- [ ] Are there new TODO/FIXME comments without issue references?
- [ ] Are all dependencies still used and up to date?
- [ ] Has any module drifted from the documented architecture?
