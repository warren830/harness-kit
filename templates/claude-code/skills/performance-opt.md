---
description: Performance optimization methodology. Use when improving speed, reducing resource usage, or fixing performance regressions.
---

# Performance Optimization Skill

## Rule #1: Measure Before Optimizing

Never optimize based on intuition. Profile first, then fix the actual bottleneck.

## Process

1. **Define the metric**: What are you measuring? (response time, memory, CPU, bundle size)
2. **Establish baseline**: Measure current performance with real or realistic data
3. **Identify bottleneck**: Profile to find where time/resources are actually spent
4. **Fix the bottleneck**: Apply targeted optimization
5. **Measure again**: Verify improvement. If no measurable improvement, revert.

## Common Bottleneck Patterns

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Slow API response | N+1 database queries | Add eager loading / batch queries |
| High memory usage | Loading entire dataset | Pagination / streaming / cursors |
| Slow page load | Large JS bundle | Code splitting / lazy loading |
| Slow database query | Missing index | Add index on queried columns |
| Slow list rendering | Re-rendering all items | Virtualization / memoization |

## Don't Optimize

- Code that runs once during startup (unless startup time is critical)
- Code that's already fast enough for the use case
- Code without tests (add tests first, optimize later)
- Readability should not be sacrificed for marginal gains
