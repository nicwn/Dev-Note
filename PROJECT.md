---
tags: [project]
last_updated: 2026-04-29
stack: [bash, jq, claude-code]
status: active
---

# Dev Note

## What it is
Automatic development documentation for Claude Code sessions. Installs two hooks (PostCompact and Stop) that silently write structured markdown logs after every session — what was built, decisions made, current status, next steps. Designed to feed an Obsidian wiki or any markdown-based second brain.

## Tech stack
- bash (all hook scripts and installer)
- jq (settings.json merge and hook scripts)
- Claude Code CLI (`claude -p` for session summary generation)

## Structure
- `.claude/hooks/` — PostCompact and Stop hook scripts
- `.claude/skills/document-session.md` — prompt template passed to `claude -p` at session end
- `.claude/CLAUDE.md` — global Claude instructions for PROJECT.md maintenance
- `.claude/settings.json` — hook registration config
- `install.sh` — one-time setup script
- `sync-to-vault.sh` — rsync helper for Obsidian users

## How to run
```bash
# install
bash install.sh

# sync logs to Obsidian vault
bash sync-to-vault.sh
bash sync-to-vault.sh my-app  # single project
```

## Current status
Stable installer with auto-jq install; minor modification to install.sh pending commit.

## Open questions / known issues
- PostCompact is a newer Claude Code feature — users should test on a throw-away session first
- Logs are keyed by working directory name; projects sharing a folder name will merge logs
