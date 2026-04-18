#!/bin/bash
# Run this once on your Hetzner server to install the claude-dev-logs system.
# Usage: bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing claude-dev-logs system..."

# Create directories
mkdir -p ~/.claude/hooks ~/.claude/skills ~/claude-dev-logs

# Copy hook scripts
cp "$SCRIPT_DIR/.claude/hooks/post-compact.sh" ~/.claude/hooks/
cp "$SCRIPT_DIR/.claude/hooks/auto-document.sh" ~/.claude/hooks/
chmod +x ~/.claude/hooks/post-compact.sh ~/.claude/hooks/auto-document.sh

# Copy skill file
cp "$SCRIPT_DIR/.claude/skills/document-session.sh" ~/.claude/skills/ 2>/dev/null || \
cp "$SCRIPT_DIR/.claude/skills/document-session.md" ~/.claude/skills/

# Copy global CLAUDE.md (prompt before overwriting if it exists)
if [ -f ~/.claude/CLAUDE.md ]; then
  echo ""
  echo "~/.claude/CLAUDE.md already exists. Showing diff:"
  diff ~/.claude/CLAUDE.md "$SCRIPT_DIR/.claude/CLAUDE.md" || true
  echo ""
  read -p "Overwrite? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cp "$SCRIPT_DIR/.claude/CLAUDE.md" ~/.claude/CLAUDE.md
    echo "Overwritten."
  else
    echo "Skipped. Merge manually if needed."
  fi
else
  cp "$SCRIPT_DIR/.claude/CLAUDE.md" ~/.claude/CLAUDE.md
fi

# Merge settings.json (preserve existing keys, add hooks)
if [ -f ~/.claude/settings.json ]; then
  echo ""
  echo "~/.claude/settings.json already exists. Merging hooks..."
  # Use jq to deep-merge: existing settings win on conflict except hooks which we add
  MERGED=$(jq -s '.[0] * .[1]' ~/.claude/settings.json "$SCRIPT_DIR/.claude/settings.json")
  echo "$MERGED" > ~/.claude/settings.json
  echo "Merged."
else
  cp "$SCRIPT_DIR/.claude/settings.json" ~/.claude/settings.json
fi

echo ""
echo "Done. Files installed:"
echo "  ~/.claude/hooks/post-compact.sh"
echo "  ~/.claude/hooks/auto-document.sh"
echo "  ~/.claude/skills/document-session.md"
echo "  ~/.claude/CLAUDE.md"
echo "  ~/.claude/settings.json"
echo "  ~/claude-dev-logs/ (empty, ready for use)"
echo ""
echo "Test it: start a claude session in any project and end it cleanly."
echo "Check: ls ~/claude-dev-logs/<project>/"
