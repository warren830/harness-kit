---
name: Kiro Hook — Lint on File Save
description: Automatically run linter when a file is saved. Catches issues immediately.
---

# Kiro Hook: Lint on Save

## Setup

Create this hook via Kiro's Command Palette → "Kiro: Open Kiro Hook UI":

| Field | Value |
|-------|-------|
| **Title** | Lint on Save |
| **Description** | Run linter when files are saved to catch issues immediately |
| **Event** | File Save |
| **File Pattern** | `*.ts,*.tsx,*.js,*.jsx` (or `*.py` for Python) |
| **Action Type** | Run Command |
| **Command** | `npx eslint {file} --fix` (or `ruff check {file} --fix`) |

## Why This Hook?

Without it, linting only happens when the agent or user explicitly runs the lint command. With it, every file save triggers a lint pass — issues are caught immediately rather than accumulating.

## Alternative: Ask Kiro

Instead of a shell command, you can use "Ask Kiro" action type:

| Field | Value |
|-------|-------|
| **Action Type** | Ask Kiro |
| **Instructions** | Check if the saved file has any linting issues. If so, fix them silently. |

This is more flexible but slower than a direct shell command.
