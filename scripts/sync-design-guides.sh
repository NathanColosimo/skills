#!/usr/bin/env bash
# Refresh the vendored guides in skills/design/guides from their upstream repos.
# Each upstream SKILL.md is renamed GUIDE.md so agents and `npx skills` don't
# treat the guides as separate skills. Only the design skill is installed.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
guides="$root/skills/design/guides"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# "<repo> <path in repo> <guide name>"
sources=(
  "anthropics/skills skills/frontend-design frontend-design"
  "emilkowalski/skill skills/emil-design-eng emil-design-eng"
  "emilkowalski/skills skills/animate animate"
  "emilkowalski/skills skills/animate-expo animate-expo"
  "emilkowalski/skills skills/review-animations review-animations"
  "emilkowalski/skills skills/improve-animations improve-animations"
  "emilkowalski/skills skills/find-animation-opportunities find-animation-opportunities"
  "emilkowalski/skills skills/break-ui break-ui"
)

for entry in "${sources[@]}"; do
  read -r repo path name <<<"$entry"
  dir="$tmp/${repo//\//_}"
  [ -d "$dir" ] || git clone --depth 1 -q "https://github.com/$repo" "$dir"
  rm -rf "${guides:?}/$name"
  mkdir -p "$guides/$name"
  cp -R "$dir/$path/." "$guides/$name/"
  mv "$guides/$name/SKILL.md" "$guides/$name/GUIDE.md"
  # Keep the upstream license with the copy.
  if ! ls "$guides/$name"/LICENSE* >/dev/null 2>&1; then
    cp "$dir"/LICENSE* "$guides/$name/" 2>/dev/null || echo "warning: no license found for $name" >&2
  fi
  echo "synced $name from $repo@$(git -C "$dir" rev-parse --short HEAD)"
done
