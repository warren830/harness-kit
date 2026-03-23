---
name: Golden Principles Template
description: Non-negotiable rules that cleanup agents check against. The "constitution" that prevents drift.
when_to_use: Any project running AI agents. These principles anchor the system against entropy.
---

# Golden Principles

> These rules are absolute. Cleanup agents and CI checks verify compliance.
> Violation of any principle triggers an automatic alert or PR block.

## Engineering Principles

1. **All code must pass tests before merge**
   - Enforcement: Stop hook (Claude Code) / after-task hook (Kiro) / CI required check
   - Violation response: Block merge, agent must fix

2. **All user input must be validated at the API boundary**
   - Enforcement: Custom linter rule or structural test
   - Violation response: Lint error with fix suggestion

3. **Dependencies flow downward only**
   - Architecture: [UI → Services → Repositories → Types]
   - Enforcement: Import restriction linter rule
   - Violation response: Lint error referencing docs/ARCHITECTURE.md

4. **No secrets in source code**
   - Enforcement: Pre-commit hook with secret scanning (e.g., gitleaks)
   - Violation response: Commit blocked with explanation

5. **Protected modules require human approval**
   - Protected paths: [src/core/, prisma/schema.prisma, src/auth/]
   - Enforcement: restrict-paths.sh hook (Claude Code)
   - Violation response: Edit blocked with reason

## How Cleanup Agents Use This

A cleanup agent (scheduled weekly) verifies:

```
For each principle:
  1. Check if enforcement mechanism is still active (hook/linter/CI exists)
  2. Check if any recent code violates the principle
  3. If violation found → open issue or PR with fix
  4. If enforcement mechanism missing → alert the team
```

## Customization

Replace the principles above with your project's actual non-negotiable rules. Guidelines:
- Keep to 5-7 principles maximum (more = noise)
- Each principle must have a concrete enforcement mechanism
- Each principle must have a defined violation response
- Review quarterly: are these still the right principles?
