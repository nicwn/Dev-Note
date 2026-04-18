#!/bin/bash
# Run this once on your server to install the Dev Note system.
# Usage: bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Dev Note..."

# --- Dependencies ---

# jq: required for settings.json merge and by hook scripts
if ! command -v jq &>/dev/null; then
  echo "jq not found — installing..."
  if command -v apt-get &>/dev/null; then
    sudo apt-get install -y jq
  elif command -v brew &>/dev/null; then
    brew install jq
  else
    echo "Error: can't install jq automatically. Install it manually and re-run."
    exit 1
  fi
fi

# --- Files ---

mkdir -p ~/.claude/hooks ~/.claude/skills ~/claude-dev-logs

# Hook scripts
cp "$SCRIPT_DIR/.claude/hooks/post-compact.sh" ~/.claude/hooks/
cp "$SCRIPT_DIR/.claude/hooks/auto-document.sh" ~/.claude/hooks/
chmod +x ~/.claude/hooks/post-compact.sh ~/.claude/hooks/auto-document.sh

# Session summary prompt
cp "$SCRIPT_DIR/.claude/skills/document-session.md" ~/.claude/skills/

# Global CLAUDE.md — append if exists, copy if not
if [ -f ~/.claude/CLAUDE.md ]; then
  # Always back up first
  BACKUP="$HOME/.claude/CLAUDE.md.bak.$(date +%F-%H%M%S)"
  cp ~/.claude/CLAUDE.md "$BACKUP"
  echo ""
  echo "Backed up ~/.claude/CLAUDE.md → $BACKUP"

  # Check if our content is already present (idempotent re-runs)
  if grep -qF "PROJECT.md — keep it current" ~/.claude/CLAUDE.md; then
    echo "Dev Note instructions already in ~/.claude/CLAUDE.md — skipping."
  else
    echo "Appending Dev Note instructions to ~/.claude/CLAUDE.md..."
    echo "" >> ~/.claude/CLAUDE.md
    echo "---" >> ~/.claude/CLAUDE.md
    cat "$SCRIPT_DIR/.claude/CLAUDE.md" >> ~/.claude/CLAUDE.md
    echo "Appended."
  fi
else
  cp "$SCRIPT_DIR/.claude/CLAUDE.md" ~/.claude/CLAUDE.md
fi

# settings.json — merge if exists, copy if not
if [ -f ~/.claude/settings.json ]; then
  echo ""
  echo "~/.claude/settings.json already exists. Merging hooks..."
  MERGED=$(jq -s '.[0] * .[1]' ~/.claude/settings.json "$SCRIPT_DIR/.claude/settings.json")
  echo "$MERGED" > ~/.claude/settings.json
  echo "Merged."
else
  cp "$SCRIPT_DIR/.claude/settings.json" ~/.claude/settings.json
fi

echo ""
echo "Done. Installed:"
echo "  ~/.claude/hooks/post-compact.sh"
echo "  ~/.claude/hooks/auto-document.sh"
echo "  ~/.claude/skills/document-session.md"
echo "  ~/.claude/CLAUDE.md"
echo "  ~/.claude/settings.json"
echo "  ~/claude-dev-logs/"
echo ""
echo "Test: start a claude session in any project, then exit."
echo "Check: ls ~/claude-dev-logs/<project>/"
