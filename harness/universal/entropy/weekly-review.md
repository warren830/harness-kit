---
name: Weekly Entropy Review Checklist
description: 30-minute weekly review to prevent harness degradation. Print or use in team standup.
---

# Weekly Entropy Review

> Time budget: 30 minutes. Run every [Monday/Friday].

## Automated Checks (5 min)

```bash
# Run entropy scanner
harness-kit scan .

# Check for stale TODOs
grep -rn "TODO\|FIXME" src/ | head -20

# Check rule file sizes
wc -l HARNESS.md CLAUDE.md .kiro/steering/*.md 2>/dev/null
```

## Rule File Health (10 min)

- [ ] **HARNESS.md**: Still accurate? Commands still work? Any new agent failures to add?
- [ ] **CLAUDE.md**: Config still relevant? Any new forbidden actions needed?
- [ ] **Kiro steering**: Product/tech/structure files match current reality?
- [ ] **File sizes**: Any rule file approaching 200 lines? (split if so)
- [ ] **Contradictions**: Any rules that conflict with each other?

## Documentation Drift (10 min)

- [ ] **ARCHITECTURE.md**: Does it match the actual code structure?
- [ ] **QUALITY.md**: Are module grades still accurate?
- [ ] **TECH-DEBT.md**: Any resolved items to move? Any new debt to log?
- [ ] **BELIEFS.md**: Are golden principles still being enforced?

## Tool Health (5 min)

- [ ] **Hooks**: Still working? (`chmod +x` intact? scripts not broken?)
- [ ] **Skills**: Still relevant? Any skills that should be added/removed?
- [ ] **CI**: Harness check workflow passing? Any new checks needed?

## Actions from This Review

| Issue Found | Action | Owner | Due |
|------------|--------|-------|-----|
| | | | |
| | | | |

## Entropy Trend

Track your harness-kit score over time:

| Date | Score | Grade | Notes |
|------|-------|-------|-------|
| [date] | [score]/70 | [grade] | [what changed] |
