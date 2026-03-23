---
paths:
  - "src/components/**"
  - "src/pages/**"
  - "src/app/**/*.tsx"
---

# UI Development Rules

- Components must handle loading, error, and empty states — not just the happy path
- All interactive elements must be keyboard accessible (Tab, Enter, Escape)
- Images must have alt text; form inputs must have labels
- Keep components under 200 lines — extract sub-components if larger
- Data fetching happens at page/container level, not inside UI components
- Use project's design system tokens for colors, spacing, and typography — don't hardcode values
