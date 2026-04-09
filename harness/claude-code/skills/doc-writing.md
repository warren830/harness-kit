---
description: Documentation writing patterns. Use when creating or updating project documentation.
---

# Documentation Writing Skill

## Who Is the Audience?

| Doc Type | Audience | Tone |
|----------|----------|------|
| HARNESS.md | AI agents | Directive, specific commands and paths |
| README | New developers | Welcoming, quick start focused |
| ARCHITECTURE.md | Experienced developers | Technical, decision-oriented |
| API docs | API consumers | Reference-style, example-heavy |
| Code comments | Future maintainers | Brief, explain "why" not "what" |

## Structure for Each Type

### README
1. One-line description
2. Quick start (copy-paste commands to get running)
3. Key features
4. Installation
5. Usage
6. Configuration
7. Contributing

### ARCHITECTURE.md
1. System overview (diagram)
2. Layers and modules
3. Dependency rules
4. Key design decisions (with rationale)

### API endpoint docs
1. Method + path
2. Description (one sentence)
3. Request (body/params/headers with types)
4. Response (success + error examples)
5. Auth requirements

## Rules

- **Examples over explanations** — show, don't tell
- **Keep it current** — outdated docs are worse than no docs
- **No obvious comments** — `// increment counter` before `counter++` is noise
- **Explain WHY, not WHAT** — code tells what, comments tell why
