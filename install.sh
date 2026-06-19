#!/bin/bash
set -e
REPO="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"

echo "Installing channel-scout skills..."
for skill_dir in "$REPO/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  dest="$SKILLS_DIR/$skill_name"
  mkdir -p "$dest"
  cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
  echo "  ✓ $skill_name"
done

# Copy shared assets into the orchestrator skill directory (rm first to avoid nested dirs on re-run)
rm -rf "$SKILLS_DIR/channel-scout/schemas" "$SKILLS_DIR/channel-scout/templates"
cp -r "$REPO/schemas" "$SKILLS_DIR/channel-scout/schemas"
cp -r "$REPO/templates" "$SKILLS_DIR/channel-scout/templates"

echo ""
echo "Done. Run /channel-scout in Claude Code to start."
