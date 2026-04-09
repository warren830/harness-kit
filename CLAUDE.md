# CLAUDE.md — harness-kit

## Import Universal Rules
@HARNESS.md

## Claude Code Specific Configuration

### Model Preferences
- Use Sonnet for routine template writing and file edits
- Use Opus for architecture decisions, methodology design, and complex analysis

### Compaction Rules
- When compacting, always preserve: current Phase progress, file list being worked on, and any design decisions made
- Prioritize retaining methodology insights over implementation details

### Workflow Rules
- Never auto-commit; always wait for explicit user instruction
- Never push to remote without user confirmation
- When creating template files, read 2-3 existing templates first to match style consistency
- Chinese translations go in separate `-zh.md` files, not inline

### Project-Specific Patterns
- Template files (harness/) follow this structure: title → overview → when to use → when not to use → template content → examples → customization guide
- Concept guides (concepts/) follow this structure: title → problem statement → when to use → when not to use → content → apply this → references
- Python tools use: argparse for CLI, pathlib for paths, yaml for config, rich for output formatting

### Forbidden Actions
- Do NOT modify files under `research/` — they are read-only reference materials
- Do NOT generate template content using AI and claim it as "best practice" — all rules must trace back to research findings or real-world usage
- Do NOT create templates longer than 200 lines — split into multiple files if needed
