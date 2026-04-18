# Global Claude Code Instructions

These instructions apply to every Claude Code session on this machine.

## PROJECT.md — keep it current

Every project must have a `PROJECT.md` in its root. It's the single source of truth for what this project is — synced to the personal wiki via `~/claude-dev-logs/`.

**On first session in a new project:** if `PROJECT.md` doesn't exist, create it using the template below, filled in from what you can infer from the codebase.

**During any session:** update `PROJECT.md` when the status, stack, or structure meaningfully changes. Don't update for minor edits — only when the snapshot would be stale.

### PROJECT.md template

```markdown
---
tags: [project]
last_updated: YYYY-MM-DD
stack: []
status: active
---

# Project Name

## What it is
2-3 sentences. What problem it solves and who uses it.

## Tech stack
- [language/framework/runtime]
- [key dependencies]
- [deployment target]

## Structure
Key directories and what they contain. Only the non-obvious parts.

## How to run
```bash
# dev
command here

# deploy
command here
```

## Current status
One sentence — where things stand.

## Open questions / known issues
- anything unresolved worth remembering
```
