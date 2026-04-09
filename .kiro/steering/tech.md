---
inclusion: always
---
# Technical Context — harness-kit

## Tech Stack
- **Documentation**: Markdown with optional YAML frontmatter
- **CLI Tools**: Python 3.11+
- **Python Tooling**: ruff (linting), mypy (type checking), pytest (testing)
- **Markdown Linting**: markdownlint
- **CI/CD**: GitHub Actions
- **License**: MIT

## Architecture Principles
- Templates are pure Markdown — zero runtime dependencies
- Tools are standalone Python scripts — no heavy frameworks
- Dual-layer architecture: concepts/ (theory) → harness/ (execution templates)
- Fowler's Guides/Sensors framework as classification system (see concepts/fowler-framework-guide.md)
- HARNESS.md is the "constitution" — platform files are "implementation details"

## File Conventions
- Concept guides: `concepts/<topic>-guide.md`
- Harness templates: `harness/<tool>/<category>/<name>.md`
- Tools: `tools/<tool-name>/<script>.py`
- Chinese translations: same name with `-zh.md` suffix (deferred to v0.3)

## Quality Standards
- Every template must include "When to use" and "When NOT to use"
- Every rule must have a concrete example
- Python code must pass `ruff check` and `mypy`
- Markdown must render cleanly with no broken formatting
