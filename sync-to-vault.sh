#!/bin/bash
# Syncs ~/claude-dev-logs/ from Hetzner to your Obsidian vault's raw/dev-logs/ folder.
# Run from your Mac. Edit HETZNER_HOST and VAULT_PATH below.
#
# Usage:
#   bash sync-to-vault.sh             # sync all
#   bash sync-to-vault.sh socgrow     # sync one project only

HETZNER_HOST="nick@157.180.88.44"
VAULT_PATH="$HOME/path/to/Obsidian Vault Nick1/raw/dev-logs"
REMOTE_LOG_PATH="~/claude-dev-logs"

mkdir -p "$VAULT_PATH"

if [ -n "$1" ]; then
  # Sync single project
  rsync -avz --progress \
    "$HETZNER_HOST:$REMOTE_LOG_PATH/$1/" \
    "$VAULT_PATH/$1/"
else
  # Sync all projects
  rsync -avz --progress \
    "$HETZNER_HOST:$REMOTE_LOG_PATH/" \
    "$VAULT_PATH/"
fi

echo ""
echo "Synced to $VAULT_PATH"
echo "Run /ingest in your vault to process any flagged files."
