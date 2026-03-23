#!/bin/bash
# Worktree Setup Script
#
# Creates an isolated git worktree for agent tasks.
# Each worktree gets its own directory, port range, and environment.
# Destroy with teardown.sh when done.
#
# Usage:
#   ./worktree-setup.sh feature-name
#   ./worktree-setup.sh fix-login-bug
#
# Result:
#   Creates: ../<project>-worktrees/feature-name/
#   Branch:  worktree/feature-name

set -euo pipefail

# ========== CUSTOMIZE ==========
BASE_PORT=3000           # Base port for dev server
PORT_RANGE=100           # Each worktree gets base + N
WORKTREE_DIR="../$(basename "$PWD")-worktrees"
# ================================

FEATURE_NAME="${1:?Usage: $0 <feature-name>}"
BRANCH_NAME="worktree/${FEATURE_NAME}"
WORKTREE_PATH="${WORKTREE_DIR}/${FEATURE_NAME}"

# Check we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "ERROR: Not in a git repository"
  exit 1
fi

# Create worktree directory
mkdir -p "$WORKTREE_DIR"

# Create branch and worktree
echo "Creating worktree: ${WORKTREE_PATH}"
echo "Branch: ${BRANCH_NAME}"

git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" HEAD

# Calculate unique port
WORKTREE_COUNT=$(git worktree list | wc -l | tr -d ' ')
UNIQUE_PORT=$((BASE_PORT + WORKTREE_COUNT * PORT_RANGE))

# Create local env override
if [ -f ".env.example" ]; then
  cp .env.example "${WORKTREE_PATH}/.env.local"
  # Override port
  echo "" >> "${WORKTREE_PATH}/.env.local"
  echo "PORT=${UNIQUE_PORT}" >> "${WORKTREE_PATH}/.env.local"
  echo "Created .env.local with PORT=${UNIQUE_PORT}"
fi

# Install dependencies in worktree
echo ""
echo "Installing dependencies..."
cd "$WORKTREE_PATH"
if [ -f "pnpm-lock.yaml" ]; then
  pnpm install --frozen-lockfile 2>/dev/null || pnpm install
elif [ -f "package-lock.json" ]; then
  npm ci 2>/dev/null || npm install
elif [ -f "requirements.txt" ]; then
  pip install -r requirements.txt
elif [ -f "pyproject.toml" ]; then
  pip install -e ".[dev]" 2>/dev/null || pip install -e .
fi

echo ""
echo "========================================="
echo "Worktree ready!"
echo "  Path:   ${WORKTREE_PATH}"
echo "  Branch: ${BRANCH_NAME}"
echo "  Port:   ${UNIQUE_PORT}"
echo ""
echo "  cd ${WORKTREE_PATH}"
echo "========================================="
