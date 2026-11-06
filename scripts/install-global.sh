#!/usr/bin/env bash
# Copy the global agent instructions to where Claude Code and Codex read them.
set -euo pipefail
src="$(cd "$(dirname "$0")/.." && pwd)/global/AGENTS.md"
for dest in "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md"; do
  rm -f "$dest"
  cp "$src" "$dest"
  echo "wrote $dest"
done
