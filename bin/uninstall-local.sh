#!/usr/bin/env bash
# Remove the symlinks bin/install-local.sh created. Leaves the repo untouched.
set -euo pipefail
for f in "$HOME"/.claude/agents/team-*.md; do
  [ -L "$f" ] && rm -v "$f"
done
[ -L "$HOME/.claude/skills/agent-team" ] && rm -v "$HOME/.claude/skills/agent-team"
echo "Uninstalled."
