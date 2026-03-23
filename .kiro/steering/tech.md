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
- Three-layer template architecture: Universal (AGENTS.md) → Platform Adapter → Platform Features
- AGENTS.md is the "constitution" — platform files are "implementation details"

## File Conventions
- Templates: `templates/<scope>/<category>/<name>.md`
- Guides: `guides/<topic>.md`
- Tools: `tools/<tool-name>/<script>.py`
- Chinese translations: same name with `-zh.md` suffix

## Quality Standards
- Every template must include "When to use" and "When NOT to use"
- Every rule must have a concrete example
- Python code must pass `ruff check` and `mypy`
- Markdown must render cleanly with no broken formatting
