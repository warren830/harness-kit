---
description: UI component implementation patterns. Use when building or modifying frontend components.
---

# UI Implementation Skill

## Component Structure

```
components/
  [ComponentName]/
    index.tsx            — Component implementation
    [ComponentName].test.tsx  — Tests
    [ComponentName].module.css — Styles (if CSS modules)
```

## Implementation Order

1. **Types first** — Define props interface
2. **Markup** — Build the HTML/JSX structure
3. **Styling** — Apply styles
4. **Logic** — Add interactivity and state
5. **Accessibility** — Add ARIA attributes, keyboard navigation
6. **Tests** — Test rendering and interactions

## Accessibility Checklist

- [ ] Interactive elements are focusable (buttons, links, inputs)
- [ ] Images have alt text
- [ ] Form inputs have labels
- [ ] Color is not the only means of conveying information
- [ ] Keyboard navigation works (Tab, Enter, Escape)
- [ ] ARIA roles on custom components (dialog, menu, tabs)

## Responsive Design

- Mobile-first: start with mobile layout, add breakpoints for larger screens
- Use relative units (rem, %, vh/vw) over fixed pixels
- Test at: 320px (mobile), 768px (tablet), 1024px (desktop), 1440px (wide)

## Common Mistakes

- Building "smart" components that fetch data — keep data fetching at page level
- Inline styles instead of CSS classes
- Missing loading and error states
- Not handling empty state (no data to display)
