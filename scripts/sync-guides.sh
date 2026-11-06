#!/usr/bin/env bash
# Refresh the vendored guides in skills/<skill>/guides from their upstream repos.
# The standards guides (tdd, diagnosing-bugs) were rewritten here, so they are
# not synced; refreshing them would undo those edits.
# Each upstream SKILL.md is renamed GUIDE.md so agents and `npx skills` don't
# treat the guides as separate skills. Only the parent skill is installed.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# "<skill> <repo> <path in repo> <guide name>"
sources=(
  "design anthropics/skills skills/frontend-design frontend-design"
  "design emilkowalski/skill skills/emil-design-eng emil-design-eng"
  "design emilkowalski/skills skills/animate animate"
  "design emilkowalski/skills skills/animate-expo animate-expo"
  "design emilkowalski/skills skills/review-animations review-animations"
  "design emilkowalski/skills skills/improve-animations improve-animations"
  "design emilkowalski/skills skills/find-animation-opportunities find-animation-opportunities"
  "design emilkowalski/skills skills/break-ui break-ui"
)

for entry in "${sources[@]}"; do
  read -r skill repo path name <<<"$entry"
  guides="$root/skills/$skill/guides"
  dir="$tmp/${repo//\//_}"
  [ -d "$dir" ] || git clone --depth 1 -q "https://github.com/$repo" "$dir"
  rm -rf "${guides:?}/$name"
  mkdir -p "$guides/$name"
  cp -R "$dir/$path/." "$guides/$name/"
  mv "$guides/$name/SKILL.md" "$guides/$name/GUIDE.md"
  rm -rf "$guides/$name/agents"
  # Keep the upstream license with the copy.
  if ! ls "$guides/$name"/LICENSE* >/dev/null 2>&1; then
    cp "$dir"/LICENSE* "$guides/$name/" 2>/dev/null || echo "warning: no license found for $name" >&2
  fi
  echo "synced $name from $repo@$(git -C "$dir" rev-parse --short HEAD)"
done
