#!/bin/bash
# Worktree Teardown Script
#
# Removes a git worktree and its branch after task completion.
# Optionally merges changes back to the main branch first.
#
# Usage:
#   ./teardown.sh feature-name          # Remove without merging
#   ./teardown.sh feature-name --merge  # Merge to current branch, then remove

set -euo pipefail

FEATURE_NAME="${1:?Usage: $0 <feature-name> [--merge]}"
MERGE="${2:-}"
WORKTREE_DIR="../$(basename "$PWD")-worktrees"
WORKTREE_PATH="${WORKTREE_DIR}/${FEATURE_NAME}"
BRANCH_NAME="worktree/${FEATURE_NAME}"

if [ ! -d "$WORKTREE_PATH" ]; then
  echo "ERROR: Worktree not found at ${WORKTREE_PATH}"
  exit 1
fi

# Optional: merge changes back
if [ "$MERGE" = "--merge" ]; then
  echo "Merging ${BRANCH_NAME} into current branch..."
  git merge "$BRANCH_NAME" --no-edit
  echo "Merged successfully."
fi

# Remove worktree
echo "Removing worktree: ${WORKTREE_PATH}"
git worktree remove "$WORKTREE_PATH" --force

# Delete branch
echo "Deleting branch: ${BRANCH_NAME}"
git branch -D "$BRANCH_NAME" 2>/dev/null || true

echo ""
echo "Teardown complete: ${FEATURE_NAME}"
