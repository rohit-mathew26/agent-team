#!/usr/bin/env bash
# Install the team into ~/.claude for every Claude Code session on this machine.
#
# Symlinks, not copies: rerun bin/build.sh after editing the spec and the change
# is live in the next session with no reinstall.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)

./bin/build.sh

AGENTS="$HOME/.claude/agents"
SKILLS="$HOME/.claude/skills"
mkdir -p "$AGENTS" "$SKILLS"

echo "Linking into ~/.claude:"
for f in plugin/agents/*.md; do
  ln -sfn "$ROOT/$f" "$AGENTS/$(basename "$f")"
  echo "  agents/$(basename "$f")"
done
ln -sfn "$ROOT/plugin/skills/agent-team" "$SKILLS/agent-team"
echo "  skills/agent-team"

echo
echo "Installed. In a new session: /agent-team <task>"
